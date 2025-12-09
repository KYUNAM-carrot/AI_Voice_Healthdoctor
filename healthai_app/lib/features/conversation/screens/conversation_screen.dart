import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String characterId;

  const ConversationScreen({
    super.key,
    required this.characterId,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // 초기 환영 메시지
    _messages.add({
      'isUser': false,
      'text': _getWelcomeMessage(),
      'timestamp': DateTime.now(),
    });
  }

  String _getWelcomeMessage() {
    switch (widget.characterId) {
      case 'choi_hyunwoo':
        return '안녕하세요! 저는 최현우 의사입니다. 무엇을 도와드릴까요?';
      case 'oh_kyungmi':
        return '안녕하세요! 저는 오경미 간호사입니다. 오늘 기분은 어떠신가요?';
      case 'lee_soojin':
        return '안녕하세요! 저는 이수진 영양사입니다. 건강한 식단에 대해 상담해드릴게요.';
      case 'park_eunseo':
        return '안녕하세요! 저는 박은서 운동 전문가입니다. 운동 계획을 함께 세워볼까요?';
      case 'jung_yujin':
        return '안녕하세요! 저는 정유진 정신건강 상담사입니다. 편하게 이야기 나눠요.';
      default:
        return '안녕하세요! 무엇을 도와드릴까요?';
    }
  }

  String _getCharacterName() {
    switch (widget.characterId) {
      case 'choi_hyunwoo':
        return '최현우 의사';
      case 'oh_kyungmi':
        return '오경미 간호사';
      case 'lee_soojin':
        return '이수진 영양사';
      case 'park_eunseo':
        return '박은서 운동 전문가';
      case 'jung_yujin':
        return '정유진 상담사';
      default:
        return 'AI 상담';
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      // 사용자 메시지 추가
      _messages.add({
        'isUser': true,
        'text': _messageController.text,
        'timestamp': DateTime.now(),
      });

      // 데모 응답 추가 (실제로는 API 호출)
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': '죄송합니다. 현재 데모 모드입니다. AI 대화 기능은 곧 구현됩니다.',
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      });
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCharacterName()),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('대화 기록 기능은 곧 구현됩니다'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'],
                  message['isUser'],
                  message['timestamp'],
                );
              },
            ),
          ),
          // 입력 영역
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.caption.copyWith(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppTheme.spaceSm),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                    vertical: AppTheme.spaceSm,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
