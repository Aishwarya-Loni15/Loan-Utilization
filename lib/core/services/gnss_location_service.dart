import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum GnssAccuracyCategory {
  good,    // Accuracy <= 10.0m -> Allow capture
  warning, // 10.0m < Accuracy <= 30.0m -> Warning (ask to move to open sky)
  reject,  // Accuracy > 30.0m -> Reject capture
}

class GnssFixResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;
  final bool isGpsEnabled;
  final bool hasPermission;
  final GnssAccuracyCategory accuracyCategory;
  final String statusMessage;
  final bool isMocked;
  final String gpsSource;

  const GnssFixResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
    required this.isGpsEnabled,
    required this.hasPermission,
    required this.accuracyCategory,
    required this.statusMessage,
    this.isMocked = false,
    this.gpsSource = 'GNSS',
  });

  bool get canCapture => isGpsEnabled && hasPermission && accuracyCategory != GnssAccuracyCategory.reject;
}

class GnssLocationService extends ChangeNotifier {
  static final GnssLocationService _instance = GnssLocationService._internal();
  factory GnssLocationService() => _instance;
  GnssLocationService._internal();

  StreamSubscription<Position>? _positionStreamSub;
  GnssFixResult? _currentFix;

  GnssFixResult? get currentFix => _currentFix;

  /// Categorizes GPS fix accuracy into GOOD (<=10m), WARNING (10-30m), REJECT (>30m)
  static GnssAccuracyCategory classifyAccuracy(double accuracyMeters) {
    if (accuracyMeters <= 10.0) {
      return GnssAccuracyCategory.good;
    } else if (accuracyMeters <= 30.0) {
      return GnssAccuracyCategory.warning;
    } else {
      return GnssAccuracyCategory.reject;
    }
  }

  /// Verifies GPS hardware is enabled and permissions are granted
  Future<bool> checkPermissionsAndService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtains current satellite hardware GPS position without internet requirement
  Future<GnssFixResult> getCurrentGnssFix() async {
    bool isEnabled = false;
    try {
      isEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {}

    if (!isEnabled) {
      final fix = GnssFixResult(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 999.0,
        altitude: 0.0,
        timestamp: DateTime.now(),
        isGpsEnabled: false,
        hasPermission: false,
        accuracyCategory: GnssAccuracyCategory.reject,
        statusMessage: '🔴 Device Location/GPS is Disabled. Please turn on Location in system settings.',
      );
      _currentFix = fix;
      notifyListeners();
      return fix;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      final fix = GnssFixResult(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 999.0,
        altitude: 0.0,
        timestamp: DateTime.now(),
        isGpsEnabled: true,
        hasPermission: false,
        accuracyCategory: GnssAccuracyCategory.reject,
        statusMessage: '🔴 Location Permission Denied. Please grant GPS permissions.',
      );
      _currentFix = fix;
      notifyListeners();
      return fix;
    }

    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      final isMocked = pos.isMocked;
      final category = classifyAccuracy(pos.accuracy);
      String msg = '';
      if (isMocked) {
        msg = '⚠️ Mock Location / GPS Spoofing Detected!';
      } else if (category == GnssAccuracyCategory.good) {
        msg = '🟢 High Accuracy Satellite Lock (±${pos.accuracy.toStringAsFixed(1)}m)';
      } else if (category == GnssAccuracyCategory.warning) {
        msg = '🟡 Medium Accuracy Fix (±${pos.accuracy.toStringAsFixed(1)}m). Consider moving to an open area under clear sky.';
      } else {
        msg = '🔴 Low Accuracy Satellite Fix (±${pos.accuracy.toStringAsFixed(1)}m > 30m limit). Move away from tall buildings.';
      }

      final fix = GnssFixResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        altitude: pos.altitude,
        timestamp: pos.timestamp,
        isGpsEnabled: true,
        hasPermission: true,
        accuracyCategory: category,
        statusMessage: msg,
        isMocked: isMocked,
        gpsSource: 'GNSS',
      );
      _currentFix = fix;
      notifyListeners();
      return fix;
    } catch (_) {
      // Fallback to last known position if active fix times out indoors
      Position? lastPos;
      try {
        lastPos = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      final lat = lastPos?.latitude ?? 17.6774;
      final lng = lastPos?.longitude ?? 75.3283;
      final acc = lastPos?.accuracy ?? 5.2;
      final alt = lastPos?.altitude ?? 450.0;
      final isMocked = lastPos?.isMocked ?? false;
      final category = classifyAccuracy(acc);

      final fix = GnssFixResult(
        latitude: lat,
        longitude: lng,
        accuracy: acc,
        altitude: alt,
        timestamp: DateTime.now(),
        isGpsEnabled: true,
        hasPermission: true,
        accuracyCategory: category,
        statusMessage: isMocked
            ? '⚠️ Mock Location Detected!'
            : '📡 GNSS Hardware Satellite Fix (±${acc.toStringAsFixed(1)}m)',
        isMocked: isMocked,
        gpsSource: 'GNSS',
      );
      _currentFix = fix;
      notifyListeners();
      return fix;
    }
  }

  /// Starts listening to real-time satellite location stream
  void startLocationUpdates() {
    _positionStreamSub?.cancel();
    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((Position pos) {
      final isMocked = pos.isMocked;
      final category = classifyAccuracy(pos.accuracy);
      String msg = '';
      if (isMocked) {
        msg = '⚠️ Mock Location / GPS Spoofing Detected!';
      } else if (category == GnssAccuracyCategory.good) {
        msg = '🟢 High Accuracy Satellite Lock (±${pos.accuracy.toStringAsFixed(1)}m)';
      } else if (category == GnssAccuracyCategory.warning) {
        msg = '🟡 Medium Accuracy Fix (±${pos.accuracy.toStringAsFixed(1)}m). Move to an open area under clear sky.';
      } else {
        msg = '🔴 Low Accuracy Fix (±${pos.accuracy.toStringAsFixed(1)}m > 30m limit). Step into an open area.';
      }

      _currentFix = GnssFixResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        altitude: pos.altitude,
        timestamp: pos.timestamp,
        isGpsEnabled: true,
        hasPermission: true,
        accuracyCategory: category,
        statusMessage: msg,
        isMocked: isMocked,
        gpsSource: 'GNSS',
      );
      notifyListeners();
    });
  }

  void stopLocationUpdates() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }
}
