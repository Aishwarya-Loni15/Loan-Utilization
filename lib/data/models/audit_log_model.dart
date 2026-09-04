class AuditLogModel {
  final String logId;
  final String userId;
  final String role;
  final String action;
  final String targetId;
  final String description;
  final DateTime timestamp;

  AuditLogModel({
    required this.logId,
    required this.userId,
    required this.role,
    required this.action,
    required this.targetId,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'userId': userId,
      'role': role,
      'action': action,
      'targetId': targetId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return AuditLogModel(
      logId: id,
      userId: map['userId'] ?? '',
      role: map['role'] ?? '',
      action: map['action'] ?? '',
      targetId: map['targetId'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}
