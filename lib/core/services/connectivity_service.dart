import 'dart:async';

/// Monitors network connectivity and broadcasts changes.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  Timer? _pollTimer;

  /// Call once at app startup to begin polling connectivity.
  void initialize() {
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Poll every 5 seconds to simulate connectivity checks.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkAndNotify();
    });
  }

  Future<bool> checkConnectivity() async {
    // In a real app, you'd use connectivity_plus or try a network request.
    // For now, optimistically return true and trust the stream for changes.
    return _isOnline;
  }

  Future<void> _checkAndNotify() async {
    // In production, replace with a real connectivity check.
    // This stub always remains online unless explicitly set offline.
    if (!_controller.isClosed) {
      _controller.add(_isOnline);
    }
  }

  /// Manually set online/offline state for simulation/testing.
  void setConnectivityState(bool online) {
    _isOnline = online;
    if (!_controller.isClosed) {
      _controller.add(_isOnline);
    }
  }

  void dispose() {
    _pollTimer?.cancel();
    _controller.close();
  }
}
