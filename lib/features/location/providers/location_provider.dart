import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationCaptureData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String? villageName;
  final String? cityName;
  final String? areaName;
  final String? districtName;
  final String? stateName;

  final bool isFromPhotoExif;
  final bool isPhotoGeotag;
  final bool isOfflineCaptured;

  const LocationCaptureData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.villageName,
    this.cityName,
    this.areaName,
    this.districtName,
    this.stateName,
    this.isFromPhotoExif = false,
    this.isPhotoGeotag = false,
    this.isOfflineCaptured = false,
  });
}

class LocationCaptureState {
  final LocationCaptureData? locationData;
  final bool isLoading;
  final String? errorMessage;

  const LocationCaptureState({
    this.locationData,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationCaptureState copyWith({
    LocationCaptureData? locationData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationCaptureState(
      locationData: locationData ?? this.locationData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final locationCaptureNotifierProvider = StateNotifierProvider<LocationCaptureNotifier, LocationCaptureState>((ref) {
  final service = ref.watch(locationServiceProvider);
  return LocationCaptureNotifier(service);
});

class LocationCaptureNotifier extends StateNotifier<LocationCaptureState> {
  final LocationService _locationService;

  LocationCaptureNotifier(this._locationService) : super(const LocationCaptureState());

  Future<void> captureGPSLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Position pos = await _locationService.getCurrentPosition();
      final liveAddr = await _locationService.getLiveAddress(pos.latitude, pos.longitude);
      final data = LocationCaptureData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
        villageName: liveAddr.villageName,
        areaName: liveAddr.areaName,
        districtName: liveAddr.districtName,
        cityName: '${liveAddr.areaName}, ${liveAddr.districtName}',
        stateName: liveAddr.stateName,
        isOfflineCaptured: liveAddr.isOffline,
      );
      state = state.copyWith(locationData: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('AppException: ', ''),
      );
    }
  }
}
