import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

/// 오디오 녹음 및 재생 서비스
/// PCM16 포맷으로 녹음하고 WebSocket으로 스트리밍
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  late final AudioPlayer _player;

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription<Uint8List>? _recordingSubscription;
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();

  /// 재생 완료 스트림 (버퍼가 비고 재생이 완전히 끝났을 때)
  final StreamController<void> _playbackCompletedController =
      StreamController<void>.broadcast();

  /// 오디오 스트림 (녹음된 데이터)
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  /// 재생 완료 스트림 (에코 방지를 위해 재생이 완료된 후에만 오디오 전송 재개)
  Stream<void> get playbackCompletedStream => _playbackCompletedController.stream;

  /// 녹음 상태
  bool get isRecording => _isRecording;

  /// 재생 상태
  bool get isPlaying => _isPlaying;

  /// 오디오 서비스 초기화
  Future<void> initialize() async {
    // 마이크 권한 요청
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('마이크 권한이 필요합니다');
    }

    // AudioPlayer 초기화 - 오디오 포커스를 요청하지 않도록 설정
    // 이렇게 하면 재생 중에도 녹음이 계속됩니다
    _player = AudioPlayer(
      // Android에서 오디오 포커스를 요청하지 않음
      // 이를 통해 녹음과 재생이 동시에 가능
      handleAudioSessionActivation: false,
    );

    print('✅ AudioService 초기화 완료 (오디오 포커스 비활성화)');
  }

  /// 마이크 권한 요청
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 녹음 시작 (PCM16 포맷)
  ///
  /// OpenAI Realtime API는 PCM16 포맷을 요구
  /// - Sample Rate: 24000 Hz (24 kHz)
  /// - Channels: 1 (Mono)
  /// - Encoding: PCM16 (16-bit)
  Future<void> startRecording() async {
    if (_isRecording) {
      print('이미 녹음 중입니다');
      return;
    }

    // 권한 확인
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('마이크 권한이 필요합니다');
    }

    try {
      // 녹음 시작
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 24000, // 24 kHz (OpenAI Realtime API 요구사항)
        numChannels: 1, // Mono
        autoGain: true,
        echoCancel: true, // 에코 캔슬 활성화 (안드로이드 기본 기능)
        noiseSuppress: true, // 노이즈 제거 활성화
      ));

      _isRecording = true;
      print('🎤 녹음 시작 (PCM16, 24kHz, Mono)');

      // 스트림 데이터를 컨트롤러로 전달
      int chunkCount = 0;
      _recordingSubscription = stream.listen(
        (audioChunk) {
          chunkCount++;
          if (chunkCount <= 5 || chunkCount % 100 == 0) {
            print('🎤 녹음 청크 #$chunkCount: ${audioChunk.length} bytes');
          }
          _audioStreamController.add(audioChunk);
        },
        onError: (error) {
          print('❌ 녹음 스트림 에러: $error');
        },
        onDone: () {
          print('⚠️ 녹음 스트림 완료됨 (총 $chunkCount 청크)');
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('녹음 시작 실패: $e');
      _isRecording = false;
      rethrow;
    }
  }

  /// 녹음 중지
  Future<void> stopRecording() async {
    if (!_isRecording) {
      print('녹음 중이 아닙니다');
      return;
    }

    try {
      await _recordingSubscription?.cancel();
      await _recorder.stop();
      _isRecording = false;
      print('녹음 중지');
    } catch (e) {
      print('녹음 중지 실패: $e');
      rethrow;
    }
  }

  // 오디오 버퍼 (스트리밍 오디오 누적)
  final List<Uint8List> _audioBuffer = [];
  bool _isProcessingBuffer = false;
  Timer? _bufferFlushTimer;  // 버퍼 플러시 타이머

  // 전체 응답을 하나로 모으는 버퍼
  final List<Uint8List> _fullResponseBuffer = [];
  bool _isCollectingResponse = false;

  // 버퍼링 설정 - 전체 응답 수집 후 한 번에 재생
  static const Duration _responseEndDelay = Duration(milliseconds: 300);  // 응답 종료 감지 지연

  /// 오디오 재생 (PCM16 바이트 데이터)
  ///
  /// OpenAI Realtime API로부터 받은 PCM16 오디오를 버퍼에 추가
  Future<void> playAudio(Uint8List pcm16Data) async {
    try {
      // 전체 응답 버퍼에 추가
      _fullResponseBuffer.add(pcm16Data);
      _isCollectingResponse = true;

      // 버퍼 플러시 타이머 취소 및 재설정
      _bufferFlushTimer?.cancel();

      // 300ms 동안 새 데이터가 없으면 응답 종료로 판단하고 재생
      _bufferFlushTimer = Timer(_responseEndDelay, () {
        if (_fullResponseBuffer.isNotEmpty && !_isProcessingBuffer) {
          _playFullResponse();
        }
      });
    } catch (e) {
      print('⚠️ 오디오 버퍼링 실패: $e');
    }
  }

  /// 전체 응답 오디오를 한 번에 재생
  Future<void> _playFullResponse() async {
    if (_isProcessingBuffer) return;
    _isProcessingBuffer = true;
    _isCollectingResponse = false;

    try {
      // 전체 버퍼 합치기
      final totalLength = _fullResponseBuffer.fold<int>(
        0, (sum, chunk) => sum + chunk.length,
      );

      if (totalLength == 0) {
        _isProcessingBuffer = false;
        return;
      }

      final fullAudio = Uint8List(totalLength);
      int offset = 0;
      for (final chunk in _fullResponseBuffer) {
        fullAudio.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      _fullResponseBuffer.clear();

      print('🔊 전체 응답 오디오 재생: ${fullAudio.length} bytes (${(fullAudio.length / 48000).toStringAsFixed(1)}초)');

      // PCM16을 WAV로 변환
      final wavData = _convertPcm16ToWav(fullAudio);

      // 재생
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(wavData, mimeType: 'audio/wav'),
        ),
      );

      _isPlaying = true;
      await _player.play();

      // 재생 완료 대기
      await _player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      _isPlaying = false;

      // 재생 중에 새 데이터가 들어왔으면 다시 재생
      if (_fullResponseBuffer.isNotEmpty) {
        _isProcessingBuffer = false;
        _playFullResponse();
        return;
      }

      // 모든 재생 완료 - 콜백 호출
      print('🔊 오디오 재생 완료 - playbackCompletedStream 발송');
      _playbackCompletedController.add(null);
    } catch (e) {
      print('오디오 재생 실패: $e');
      _isPlaying = false;
      _fullResponseBuffer.clear();
      _playbackCompletedController.add(null);
    } finally {
      _isProcessingBuffer = false;
    }
  }

  /// 오디오 버퍼를 처리하여 재생 (레거시 - 사용 안함)
  Future<void> _processAudioBuffer() async {
    // 이 메서드는 더 이상 사용되지 않음
  }

  /// 버퍼의 모든 오디오를 하나로 합침
  Uint8List _combineAudioBuffers() {
    if (_audioBuffer.isEmpty) return Uint8List(0);

    final totalLength = _audioBuffer.fold<int>(
      0,
      (sum, buffer) => sum + buffer.length,
    );

    final combined = Uint8List(totalLength);
    int offset = 0;

    for (final buffer in _audioBuffer) {
      combined.setRange(offset, offset + buffer.length, buffer);
      offset += buffer.length;
    }

    return combined;
  }

  /// PCM16 데이터를 WAV 파일로 변환
  ///
  /// [pcm16Data]: PCM16 오디오 데이터
  /// Returns: WAV 포맷 바이트 데이터 (헤더 포함)
  Uint8List _convertPcm16ToWav(Uint8List pcm16Data) {
    final int sampleRate = 24000;
    final int numChannels = 1;
    final int bitsPerSample = 16;
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int dataSize = pcm16Data.length;
    final int fileSize = 36 + dataSize;

    final BytesBuilder builder = BytesBuilder();

    // RIFF 헤더
    builder.add(utf8Encode('RIFF'));
    builder.add(_int32ToBytes(fileSize));
    builder.add(utf8Encode('WAVE'));

    // fmt 서브청크
    builder.add(utf8Encode('fmt '));
    builder.add(_int32ToBytes(16)); // fmt 청크 크기
    builder.add(_int16ToBytes(1)); // PCM 포맷
    builder.add(_int16ToBytes(numChannels));
    builder.add(_int32ToBytes(sampleRate));
    builder.add(_int32ToBytes(byteRate));
    builder.add(_int16ToBytes(blockAlign));
    builder.add(_int16ToBytes(bitsPerSample));

    // data 서브청크
    builder.add(utf8Encode('data'));
    builder.add(_int32ToBytes(dataSize));
    builder.add(pcm16Data);

    return builder.toBytes();
  }

  /// UTF-8 인코딩 헬퍼
  List<int> utf8Encode(String str) {
    return str.codeUnits;
  }

  /// int32를 Little Endian 바이트로 변환
  List<int> _int32ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  /// int16를 Little Endian 바이트로 변환
  List<int> _int16ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
    ];
  }

  /// MP3 오디오 재생 (환영 메시지용)
  ///
  /// [mp3Data]: MP3 바이트 데이터
  Future<void> playMp3Audio(Uint8List mp3Data) async {
    try {
      // MP3 데이터를 Data URI로 변환하여 재생
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(mp3Data, mimeType: 'audio/mpeg'),
        ),
      );

      _isPlaying = true;
      await _player.play();

      // 재생 완료 대기
      await _player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      _isPlaying = false;
    } catch (e) {
      print('⚠️ MP3 오디오 재생 실패: $e');
      _isPlaying = false;
      // 에러를 전파하지 않음 - 오디오 재생 실패가 전체 세션을 종료시키지 않도록
    }
  }

  /// 재생 중지
  Future<void> stopPlaying() async {
    if (!_isPlaying) {
      return;
    }

    await _player.stop();
    _isPlaying = false;
    print('재생 중지');
  }

  /// 리소스 정리
  Future<void> dispose() async {
    _bufferFlushTimer?.cancel();
    _fullResponseBuffer.clear();
    _audioBuffer.clear();
    await stopRecording();
    await stopPlaying();
    await _recordingSubscription?.cancel();
    await _recorder.dispose();
    await _player.dispose();
    await _audioStreamController.close();
    await _playbackCompletedController.close();
  }
}
