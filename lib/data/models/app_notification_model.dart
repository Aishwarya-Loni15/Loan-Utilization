import '../../core/enums/user_role.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotificationEntity {
  final String? relatedLoanId;

  const AppNotificationModel({
    required super.id,
    required super.targetUserId,
    required super.targetRole,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    super.isRead,
    super.payload,
    this.relatedLoanId,
  });

  factory AppNotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return AppNotificationModel(
      id: id.isNotEmpty ? id : (map['notificationId'] ?? ''),
      targetUserId: map['userId'] ?? map['targetUserId'] ?? '',
      targetRole: UserRole.fromString(map['targetRole']),
      title: map['title'] ?? '',
      message: map['message'] ?? map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.loanLinked,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      payload: map['payload'],
      relatedLoanId: map['relatedLoanId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': id,
      'userId': targetUserId,
      'title': title,
      'message': message,
      'type': type.name,
      'relatedLoanId': relatedLoanId ?? payload,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
