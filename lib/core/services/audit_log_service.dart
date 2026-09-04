import 'package:flutter/foundation.dart';
import 'package:laon/data/models/audit_log_model.dart';

enum AuditAction {
  login('LOGIN'),
  loanRegistration('LOAN_REGISTRATION'),
  loanLinking('LOAN_LINKING'),
  proofUpload('PROOF_UPLOAD'),
  aiVerification('AI_VERIFICATION'),
  approval('APPROVAL'),
  rejection('REJECTION'),
  resubmission('RESUBMISSION'),
  userChanges('USER_CHANGES');

  final String code;
  const AuditAction(this.code);
}

class AuditLogService {
  static final AuditLogService _instance = AuditLogService._internal();
  factory AuditLogService() => _instance;
  AuditLogService._internal();

  final List<AuditLogModel> _logs = [
    AuditLogModel(
      logId: 'log_001',
      userId: 'user_admin_01',
      role: 'ADMIN',
      action: AuditAction.login.code,
      targetId: 'user_admin_01',
      description: 'System Administrator logged in successfully',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AuditLogModel(
      logId: 'log_002',
      userId: 'user_bank_sbi',
      role: 'BANK_MANAGER',
      action: AuditAction.loanRegistration.code,
      targetId: 'LN20260001',
      description: 'Registered offline loan account LN20260001 for PM-KUSUM Scheme',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AuditLogModel(
      logId: 'log_003',
      userId: 'user_ben_01',
      role: 'BENEFICIARY',
      action: AuditAction.loanLinking.code,
      targetId: 'LN20260001',
      description: 'Linked loan LN20260001 via single-use QR token LL-TOKEN-9412',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    ),
    AuditLogModel(
      logId: 'log_004',
      userId: 'user_ben_01',
      role: 'BENEFICIARY',
      action: AuditAction.proofUpload.code,
      targetId: 'sub_001_verified',
      description: 'Uploaded geotagged photo evidence package for solar pump installation',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AuditLogModel(
      logId: 'log_005',
      userId: 'system_ai',
      role: 'SYSTEM_AI',
      action: AuditAction.aiVerification.code,
      targetId: 'sub_001_verified',
      description: 'AI Engine analyzed evidence: PURPOSE_MATCH (96.5% Confidence)',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    AuditLogModel(
      logId: 'log_006',
      userId: 'user_bank_sbi',
      role: 'BANK_MANAGER',
      action: AuditAction.approval.code,
      targetId: 'sub_001_verified',
      description: 'Bank Manager approved proof submission for ₹1,85,000',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AuditLogModel(
      logId: 'log_007',
      userId: 'user_bank_sbi',
      role: 'BANK_MANAGER',
      action: AuditAction.rejection.code,
      targetId: 'sub_002_flagged',
      description: 'Bank Manager rejected proof: PURPOSE_MISMATCH smartwatch flag',
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    AuditLogModel(
      logId: 'log_008',
      userId: 'user_bank_sbi',
      role: 'BANK_MANAGER',
      action: AuditAction.resubmission.code,
      targetId: 'sub_003_resubmit',
      description: 'Requested resubmission for clearer invoice document',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    AuditLogModel(
      logId: 'log_009',
      userId: 'user_admin_01',
      role: 'ADMIN',
      action: AuditAction.userChanges.code,
      targetId: 'user_bank_sbi',
      description: 'Updated jurisdiction access assignment for Bank Manager Amitabh Deshmukh',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  List<AuditLogModel> get logs => List.unmodifiable(_logs);

  void logAction({
    required String userId,
    required String role,
    required AuditAction action,
    required String targetId,
    required String description,
  }) {
    final log = AuditLogModel(
      logId: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      role: role,
      action: action.code,
      targetId: targetId,
      description: description,
      timestamp: DateTime.now(),
    );

    _logs.insert(0, log);
    debugPrint('📝 AUDIT LOG RECORDED: [${action.code}] $description');
  }
}
