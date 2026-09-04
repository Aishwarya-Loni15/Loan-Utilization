import 'package:laon/core/services/local_storage_service.dart';
import 'package:laon/data/models/utilization_submission_model.dart';
import 'package:laon/data/models/ai_analysis_model.dart';
import 'package:laon/core/enums/sync_status.dart';

const String _kPendingSubmissionsKey = 'pending_submissions_db';

/// A lightweight local database for offline-first pending submissions.
/// Backed by [LocalStorageService] (SharedPreferences + JSON serialization).
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  final LocalStorageService _storage = LocalStorageService();

  Future<void> init() async {
    await _storage.init();
  }

  // ─── Raw Records ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _loadAll() {
    return _storage.getJsonList(_kPendingSubmissionsKey);
  }

  Future<void> _saveAll(List<Map<String, dynamic>> records) async {
    await _storage.setJsonList(_kPendingSubmissionsKey, records);
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────────

  /// Insert a new pending submission record.
  Future<void> insertPendingSubmission({
    required UtilizationSubmissionModel submission,
    required AiAnalysisModel aiAnalysis,
  }) async {
    final records = _loadAll();
    final record = {
      'submissionId': submission.submissionId,
      'submission': submission.toMap(),
      'aiAnalysis': aiAnalysis.toMap(),
      'syncStatus': SyncStatus.pendingSync.value,
      'queuedAt': DateTime.now().toIso8601String(),
      'attempts': 0,
      'lastError': null,
    };
    // Avoid duplicates
    records.removeWhere((r) => r['submissionId'] == submission.submissionId);
    records.add(record);
    await _saveAll(records);
  }

  /// Get all pending submission records.
  List<Map<String, dynamic>> getAllPendingRecords() => _loadAll();

  /// Get a specific record by ID.
  Map<String, dynamic>? getRecordById(String submissionId) {
    return _loadAll().firstWhere(
      (r) => r['submissionId'] == submissionId,
      orElse: () => {},
    ).isEmpty
        ? null
        : _loadAll().firstWhere((r) => r['submissionId'] == submissionId);
  }

  /// Update sync status of a record.
  Future<void> updateSyncStatus(String submissionId, SyncStatus status, {String? error}) async {
    final records = _loadAll();
    final idx = records.indexWhere((r) => r['submissionId'] == submissionId);
    if (idx == -1) return;
    records[idx]['syncStatus'] = status.value;
    if (error != null) records[idx]['lastError'] = error;
    if (status == SyncStatus.syncing) {
      records[idx]['attempts'] = (records[idx]['attempts'] as int? ?? 0) + 1;
    }
    await _saveAll(records);
  }

  /// Remove a successfully synced record.
  Future<void> deleteSyncedRecord(String submissionId) async {
    final records = _loadAll();
    records.removeWhere((r) => r['submissionId'] == submissionId);
    await _saveAll(records);
  }

  /// Count records by status.
  int countByStatus(SyncStatus status) {
    return _loadAll().where((r) => r['syncStatus'] == status.value).length;
  }

  /// Clear all records (use with caution).
  Future<void> clearAll() async {
    await _saveAll([]);
  }
}
