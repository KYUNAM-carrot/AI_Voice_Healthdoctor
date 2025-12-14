import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/conversation_history_service.dart';
import '../../../core/theme/app_theme.dart';

/// 대화 기록 목록 화면
///
/// SharedPreferences에 저장된 대화 기록 목록을 표시
class ConversationHistoryScreen extends StatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  State<ConversationHistoryScreen> createState() => _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  List<ConversationHistory> _histories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() => _isLoading = true);
    final histories = await ConversationHistoryService.getConversationHistories();
    setState(() {
      _histories = histories;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistory(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화 기록 삭제'),
        content: const Text('이 대화 기록을 삭제하시겠습니까?'),
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

    if (confirmed == true) {
      await ConversationHistoryService.deleteConversation(id);
      _loadHistories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('대화 기록이 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담 기록'),
        actions: [
          if (_histories.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'delete_all') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('모든 기록 삭제'),
                      content: const Text('모든 대화 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('모두 삭제'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ConversationHistoryService.clearAllConversations();
                    _loadHistories();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('모든 대화 기록이 삭제되었습니다')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('모든 기록 삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '상담 기록이 없습니다',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 주치의와 상담을 시작해보세요',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/characters'),
            icon: const Icon(Icons.mic),
            label: const Text('상담 시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // 날짜별로 그룹화
    final grouped = <String, List<ConversationHistory>>{};
    for (final history in _histories) {
      final dateKey = _formatDateGroup(history.startTime);
      grouped.putIfAbsent(dateKey, () => []).add(history);
    }

    return RefreshIndicator(
      onRefresh: _loadHistories,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final dateKey = grouped.keys.elementAt(index);
          final items = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  dateKey,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // 해당 날짜의 대화 목록
              ...items.map((history) => _buildHistoryItem(history)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(ConversationHistory history) {
    return Dismissible(
      key: Key(history.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('대화 기록 삭제'),
            content: const Text('이 대화 기록을 삭제하시겠습니까?'),
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
      },
      onDismissed: (direction) async {
        await ConversationHistoryService.deleteConversation(history.id);
        _loadHistories();
      },
      child: ListTile(
        onTap: () => context.push('/conversation-history/${history.id}'),
        leading: CircleAvatar(
          backgroundColor: _getCharacterColor(history.characterId).withOpacity(0.1),
          child: Text(
            history.characterName.substring(0, 1),
            style: TextStyle(
              color: _getCharacterColor(history.characterId),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                history.characterName,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(history.startTime),
              style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (history.familyProfileName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 12, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${history.familyProfileName}님 상담',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              history.summary ?? _getPreviewText(history.messages),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(history.durationSeconds),
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chat_bubble_outline, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  '${history.messages.length}개 메시지',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () => _showHistoryOptions(history),
        ),
      ),
    );
  }

  void _showHistoryOptions(ConversationHistory history) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('상세 보기'),
              onTap: () {
                Navigator.pop(context);
                context.push('/conversation-history/${history.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteHistory(history.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) return '오늘';
    if (difference == 1) return '어제';
    if (difference < 7) return '${difference}일 전';
    if (date.year == now.year) {
      return '${date.month}월 ${date.day}일';
    }
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}분 ${secs}초';
    }
    return '${secs}초';
  }

  String _getPreviewText(List<ConversationHistoryMessage> messages) {
    if (messages.isEmpty) return '대화 내용 없음';

    // 첫 번째 사용자 메시지 찾기
    final userMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );
    return userMessage.text.length > 100
        ? '${userMessage.text.substring(0, 100)}...'
        : userMessage.text;
  }

  Color _getCharacterColor(String characterId) {
    switch (characterId) {
      case 'park_jihoon':
        return const Color(0xFF2196F3); // 내과 - 파랑
      case 'choi_hyunwoo':
        return const Color(0xFF9C27B0); // 정신건강 - 보라
      case 'oh_kyungmi':
        return const Color(0xFF4CAF50); // 영양 - 초록
      case 'lee_soojin':
        return const Color(0xFFE91E63); // 여성건강 - 핑크
      case 'park_eunseo':
        return const Color(0xFFFF9800); // 소아청소년 - 주황
      case 'jung_yujin':
        return const Color(0xFF607D8B); // 노인의학 - 회색
      default:
        return AppTheme.primary;
    }
  }
}
