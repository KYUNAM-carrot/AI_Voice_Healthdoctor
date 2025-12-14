import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/conversation_history_service.dart';
import '../../../core/theme/app_theme.dart';

/// 대화 기록 상세 화면
///
/// 특정 대화의 전체 내용을 표시
class ConversationHistoryDetailScreen extends StatefulWidget {
  final String conversationId;

  const ConversationHistoryDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationHistoryDetailScreen> createState() =>
      _ConversationHistoryDetailScreenState();
}

class _ConversationHistoryDetailScreenState
    extends State<ConversationHistoryDetailScreen> {
  ConversationHistory? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history =
        await ConversationHistoryService.getConversationById(widget.conversationId);
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_history?.characterName ?? '상담 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '복사',
            onPressed: _history != null ? _copyConversation : null,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '공유',
            onPressed: _history != null ? _shareConversation : null,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteConversation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('삭제', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history == null
              ? _buildNotFound()
              : _buildContent(),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '대화 기록을 찾을 수 없습니다',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final history = _history!;

    return Column(
      children: [
        // 상담 정보 헤더
        _buildInfoHeader(history),

        // 대화 내용
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.messages.length,
            itemBuilder: (context, index) {
              final message = history.messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoHeader(ConversationHistory history) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    _getCharacterColor(history.characterId).withOpacity(0.1),
                child: Text(
                  history.characterName.substring(0, 1),
                  style: TextStyle(
                    color: _getCharacterColor(history.characterId),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.characterName,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (history.familyProfileName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${history.familyProfileName}님 상담',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today,
                text: _formatDate(history.startTime),
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.access_time,
                text: _formatDuration(history.durationSeconds),
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.chat_bubble_outline,
                text: '${history.messages.length}개',
              ),
            ],
          ),
          if (history.summary != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.summarize_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      history.summary!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ConversationHistoryMessage message) {
    if (message.isUser) {
      // 사용자 메시지
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatMessageTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // AI 응답
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 아이콘과 레이블
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    size: 14,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI 주치의',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // AI 응답 텍스트
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF1A1A2E),
              ),
            ),
            // 구분선
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ],
        ),
      );
    }
  }

  void _copyConversation() {
    if (_history == null) return;

    final text = _getConversationText();
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('대화 내용이 클립보드에 복사되었습니다'),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareConversation() {
    if (_history == null) return;

    final text = _getConversationText();
    Clipboard.setData(ClipboardData(text: text));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('상담 내용 공유'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('상담 내용이 클립보드에 복사되었습니다.\n메시지, 이메일, 메모 앱 등에 붙여넣기 하세요.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 기록 삭제'),
        content: const Text('이 대화 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && _history != null) {
      await ConversationHistoryService.deleteConversation(_history!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대화 기록이 삭제되었습니다')),
        );
        context.pop();
      }
    }
  }

  String _getConversationText() {
    if (_history == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════');
    buffer.writeln('AI 건강 상담 기록');
    buffer.writeln('상담사: ${_history!.characterName}');
    if (_history!.familyProfileName != null) {
      buffer.writeln('상담 대상: ${_history!.familyProfileName}');
    }
    buffer.writeln('날짜: ${_formatDate(_history!.startTime)}');
    buffer.writeln('상담 시간: ${_formatDuration(_history!.durationSeconds)}');
    buffer.writeln('═══════════════════════════════\n');

    for (final message in _history!.messages) {
      if (message.isUser) {
        buffer.writeln('👤 나: ${message.text}');
      } else {
        buffer.writeln('🩺 AI 주치의: ${message.text}');
      }
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════');
    buffer.writeln('HealthAI - AI 건강 주치의 앱');
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }

  String _formatMessageTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}분 ${secs}초';
    }
    return '${secs}초';
  }

  Color _getCharacterColor(String characterId) {
    switch (characterId) {
      case 'park_jihoon':
        return const Color(0xFF2196F3);
      case 'choi_hyunwoo':
        return const Color(0xFF9C27B0);
      case 'oh_kyungmi':
        return const Color(0xFF4CAF50);
      case 'lee_soojin':
        return const Color(0xFFE91E63);
      case 'park_eunseo':
        return const Color(0xFFFF9800);
      case 'jung_yujin':
        return const Color(0xFF607D8B);
      default:
        return AppTheme.primary;
    }
  }
}
