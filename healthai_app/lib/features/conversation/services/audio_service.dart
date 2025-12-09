import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

/// 오디오 녹음 및 재생 서비스
/// PCM16 포맷으로 녹음하고 WebSocket으로 스트리밍
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;

  StreamSubscription<Uint8List>? _recordingSubscription;
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();

  /// 오디오 스트림 (녹음된 데이터)
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  /// 녹음 상태
  bool get isRecording => _isRecording;

  /// 재생 상태
  bool get isPlaying => _isPlaying;

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
        echoCancel: true,
        noiseSuppress: true,
      ));

      _isRecording = true;
      print('녹음 시작 (PCM16, 24kHz, Mono)');

      // 스트림 데이터를 컨트롤러로 전달
      _recordingSubscription = stream.listen((audioChunk) {
        _audioStreamController.add(audioChunk);
      });
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

  /// 오디오 재생 (PCM16 바이트 데이터)
  ///
  /// OpenAI Realtime API로부터 받은 PCM16 오디오 재생
  /// 주의: just_audio는 PCM16을 직접 재생하지 못하므로 WAV 헤더 추가 필요
  Future<void> playAudio(Uint8List pcm16Data) async {
    try {
      // PCM16을 WAV 파일로 변환 (헤더 추가)
      final wavData = _convertPcm16ToWav(pcm16Data);

      // 메모리에서 재생
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(wavData, mimeType: 'audio/wav'),
        ),
      );

      _isPlaying = true;
      await _player.play();

      // 재생 완료 리스너
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    } catch (e) {
      print('오디오 재생 실패: $e');
      _isPlaying = false;
      rethrow;
    }
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
    await stopRecording();
    await stopPlaying();
    await _recordingSubscription?.cancel();
    await _recorder.dispose();
    await _player.dispose();
    await _audioStreamController.close();
  }
}
