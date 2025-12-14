import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회원 탈퇴 정보 모델
class WithdrawalInfo {
  final String id;
  final String userId;
  final String userName;
  final String reason;
  final DateTime withdrawalDate;

  WithdrawalInfo({
    String? id,
    required this.userId,
    required this.userName,
    required this.reason,
    required this.withdrawalDate,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'reason': reason,
        'withdrawalDate': withdrawalDate.toIso8601String(),
      };

  factory WithdrawalInfo.fromJson(Map<String, dynamic> json) => WithdrawalInfo(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        reason: json['reason'],
        withdrawalDate: DateTime.parse(json['withdrawalDate']),
      );
}

/// 탈퇴 정보 목록 Notifier
class WithdrawalListNotifier extends StateNotifier<List<WithdrawalInfo>> {
  WithdrawalListNotifier() : super([]);

  /// 탈퇴 정보 추가
  void addWithdrawal(WithdrawalInfo info) {
    state = [...state, info];
    // TODO: 백엔드 API로 탈퇴 정보 전송
    _sendToBackend(info);
  }

  /// 백엔드로 탈퇴 정보 전송
  Future<void> _sendToBackend(WithdrawalInfo info) async {
    // TODO: 실제 백엔드 API 연동
    print('탈퇴 정보 전송: ${info.toJson()}');
  }

  /// 탈퇴 정보 목록 로드 (관리자용)
  Future<void> loadWithdrawals() async {
    // TODO: 백엔드에서 탈퇴 정보 목록 로드
    // 현재는 로컬 상태만 사용
  }

  /// 탈퇴 정보 삭제 (관리자용)
  void removeWithdrawal(String id) {
    state = state.where((info) => info.id != id).toList();
  }

  /// 탈퇴 사유별 통계
  Map<String, int> getReasonStatistics() {
    final stats = <String, int>{};
    for (final info in state) {
      final baseReason = info.reason.startsWith('기타:') ? '기타' : info.reason;
      stats[baseReason] = (stats[baseReason] ?? 0) + 1;
    }
    return stats;
  }
}

/// 탈퇴 정보 목록 Provider
final withdrawalListProvider =
    StateNotifierProvider<WithdrawalListNotifier, List<WithdrawalInfo>>((ref) {
  return WithdrawalListNotifier();
});

/// 탈퇴 통계 Provider
final withdrawalStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(withdrawalListProvider.notifier);
  return notifier.getReasonStatistics();
});
