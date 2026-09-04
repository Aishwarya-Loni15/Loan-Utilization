import 'package:laon/core/enums/sync_status.dart';
import 'package:laon/data/datasources/local/local_database.dart';
import 'package:laon/data/models/ai_analysis_model.dart';
import 'package:laon/data/models/utilization_submission_model.dart';

/// Data Access Object for pending submissions in the local offline database.
class PendingSubmissionDao {
  static final PendingSubmissionDao _instance = PendingSubmissionDao._internal();
  factory PendingSubmissionDao() => _instance;
  PendingSubmissionDao._internal();

  final LocalDatabase _db = LocalDatabase();

  // ─── Write ───────────────────────────────────────────────────────────────────

  /// Enqueue a submission for upload.
  Future<void> enqueue({
    required UtilizationSubmissionModel submission,
    required AiAnalysisModel aiAnalysis,
  }) async {
    await _db.insertPendingSubmission(
      submission: submission,
      aiAnalysis: aiAnalysis,
    );
  }

  // ─── Read ────────────────────────────────────────────────────────────────────

  /// Get all submissions that are waiting to sync.
  List<PendingSubmissionRecord> getPendingSync() {
    return _db
        .getAllPendingRecords()
        .where((r) => r['syncStatus'] == SyncStatus.pendingSync.value ||
            r['syncStatus'] == SyncStatus.failed.value)
        .map((r) => PendingSubmissionRecord.fromMap(r))
        .toList();
  }

  /// Get all records regardless of status.
  List<PendingSubmissionRecord> getAll() {
    return _db
        .getAllPendingRecords()
        .map((r) => PendingSubmissionRecord.fromMap(r))
        .toList();
  }

  /// Count items pending sync.
  int countPending() => _db.countByStatus(SyncStatus.pendingSync);

  /// Count items that failed sync.
  int countFailed() => _db.countByStatus(SyncStatus.failed);

  // ─── Status Updates ──────────────────────────────────────────────────────────

  Future<void> markSyncing(String submissionId) async {
    await _db.updateSyncStatus(submissionId, SyncStatus.syncing);
  }

  Future<void> markFailed(String submissionId, String error) async {
    await _db.updateSyncStatus(submissionId, SyncStatus.failed, error: error);
  }

  Future<void> markSynced(String submissionId) async {
    await _db.deleteSyncedRecord(submissionId);
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _db.clearAll();
  }
}

/// A typed record from the local pending submissions database.
class PendingSubmissionRecord {
  final String submissionId;
  final UtilizationSubmissionModel submission;
  final AiAnalysisModel aiAnalysis;
  final SyncStatus syncStatus;
  final DateTime queuedAt;
  final int attempts;
  final String? lastError;

  const PendingSubmissionRecord({
    required this.submissionId,
    required this.submission,
    required this.aiAnalysis,
    required this.syncStatus,
    required this.queuedAt,
    required this.attempts,
    this.lastError,
  });

  factory PendingSubmissionRecord.fromMap(Map<String, dynamic> map) {
    final submissionMap = map['submission'] as Map<String, dynamic>;
    final aiMap = map['aiAnalysis'] as Map<String, dynamic>;
    return PendingSubmissionRecord(
      submissionId: map['submissionId'] as String,
      submission: UtilizationSubmissionModel.fromMap(
        submissionMap,
        submissionMap['submissionId'] as String? ?? map['submissionId'] as String,
      ),
      aiAnalysis: AiAnalysisModel.fromMap(
        aiMap,
        aiMap['analysisId'] as String? ?? 'ai_${map['submissionId']}',
      ),
      syncStatus: SyncStatus.fromString(map['syncStatus'] as String?),
      queuedAt: DateTime.tryParse(map['queuedAt'] as String? ?? '') ?? DateTime.now(),
      attempts: (map['attempts'] as int?) ?? 0,
      lastError: map['lastError'] as String?,
    );
  }
}
