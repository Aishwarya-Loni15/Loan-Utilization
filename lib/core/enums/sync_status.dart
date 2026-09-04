/// Sync status for offline-first submission queue items.
enum SyncStatus {
  pendingSync('PENDING_SYNC'),
  syncing('SYNCING'),
  synced('SYNCED'),
  failed('FAILED');

  const SyncStatus(this.value);
  final String value;

  static SyncStatus fromString(String? value) {
    switch (value) {
      case 'PENDING_SYNC':
        return SyncStatus.pendingSync;
      case 'SYNCING':
        return SyncStatus.syncing;
      case 'SYNCED':
        return SyncStatus.synced;
      case 'FAILED':
        return SyncStatus.failed;
      default:
        return SyncStatus.pendingSync;
    }
  }

  String get displayName {
    switch (this) {
      case SyncStatus.pendingSync:
        return 'Pending Sync';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.failed:
        return 'Sync Failed';
    }
  }
}
