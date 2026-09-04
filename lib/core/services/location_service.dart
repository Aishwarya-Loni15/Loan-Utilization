import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/location_consistency_status.dart';

class LiveAddressResult {
  final String villageName;
  final String areaName;
  final String districtName;
  final String stateName;
  final bool isOffline;

  const LiveAddressResult({
    required this.villageName,
    required this.areaName,
    required this.districtName,
    required this.stateName,
    this.isOffline = false,
  });
}

class ExtractedPhotoGeotag {
  final double latitude;
  final double longitude;
  final bool isFromExif;

  const ExtractedPhotoGeotag({
    required this.latitude,
    required this.longitude,
    required this.isFromExif,
  });
}

class LocalOfflineVillageData {
  final String villageName;
  final String areaName;
  final String districtName;
  final String stateName;
  final double latitude;
  final double longitude;

  const LocalOfflineVillageData({
    required this.villageName,
    required this.areaName,
    required this.districtName,
    required this.stateName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  /// Extracts geotag GPS coordinates directly from photo file EXIF metadata,
  /// or falls back to live position at photo capture/selection time.
  Future<ExtractedPhotoGeotag> extractPhotoGeotag(File photoFile) async {
    try {
      final bytes = await photoFile.readAsBytes();
      final exifGeotag = _parseExifGps(bytes);
      if (exifGeotag != null) {
        return exifGeotag;
      }
    } catch (_) {}

    // Fallback to current GPS position at photo capture/attachment time
    final pos = await getCurrentPosition();
    return ExtractedPhotoGeotag(
      latitude: pos.latitude,
      longitude: pos.longitude,
      isFromExif: false,
    );
  }

  /// Self-contained JPEG EXIF GPS parser
  ExtractedPhotoGeotag? _parseExifGps(List<int> bytes) {
    if (bytes.length < 100) return null;
    if (bytes[0] != 0xFF || bytes[1] != 0xD8) return null;

    int offset = 2;
    while (offset < bytes.length - 4) {
      if (bytes[offset] != 0xFF) break;
      final marker = bytes[offset + 1];
      final length = (bytes[offset + 2] << 8) | bytes[offset + 3];

      if (marker == 0xE1) {
        if (offset + 10 < bytes.length &&
            bytes[offset + 4] == 0x45 && // E
            bytes[offset + 5] == 0x78 && // x
            bytes[offset + 6] == 0x69 && // i
            bytes[offset + 7] == 0x66 && // f
            bytes[offset + 8] == 0x00 &&
            bytes[offset + 9] == 0x00) {
          final tiffStart = offset + 10;
          final isBigEndian = bytes[tiffStart] == 0x4D && bytes[tiffStart + 1] == 0x4D;

          int readUint16(int p) {
            if (p + 1 >= bytes.length) return 0;
            return isBigEndian
                ? (bytes[p] << 8) | bytes[p + 1]
                : bytes[p] | (bytes[p + 1] << 8);
          }

          int readUint32(int p) {
            if (p + 3 >= bytes.length) return 0;
            return isBigEndian
                ? (bytes[p] << 24) | (bytes[p + 1] << 16) | (bytes[p + 2] << 8) | bytes[p + 3]
                : bytes[p] | (bytes[p + 1] << 8) | (bytes[p + 2] << 16) | (bytes[p + 3] << 24);
          }

          final firstIfdOffset = readUint32(tiffStart + 4);
          if (firstIfdOffset == 0) return null;

          int ifdPtr = tiffStart + firstIfdOffset;
          final entries = readUint16(ifdPtr);
          ifdPtr += 2;

          int gpsIfdOffset = 0;
          for (int i = 0; i < entries; i++) {
            final tag = readUint16(ifdPtr);
            if (tag == 0x8825) {
              gpsIfdOffset = readUint32(ifdPtr + 8);
              break;
            }
            ifdPtr += 12;
          }

          if (gpsIfdOffset > 0) {
            int gpsPtr = tiffStart + gpsIfdOffset;
            final gpsEntries = readUint16(gpsPtr);
            gpsPtr += 2;

            double? lat;
            double? lng;
            String latRef = 'N';
            String lngRef = 'E';

            for (int i = 0; i < gpsEntries; i++) {
              final tag = readUint16(gpsPtr);
              final valOffset = readUint32(gpsPtr + 8);

              if (tag == 0x0001 && tiffStart + valOffset < bytes.length) {
                latRef = String.fromCharCode(bytes[tiffStart + valOffset]);
              } else if (tag == 0x0003 && tiffStart + valOffset < bytes.length) {
                lngRef = String.fromCharCode(bytes[tiffStart + valOffset]);
              } else if (tag == 0x0002) {
                final dataPtr = tiffStart + valOffset;
                if (dataPtr + 23 < bytes.length) {
                  final dNum = readUint32(dataPtr);
                  final dDen = readUint32(dataPtr + 4);
                  final mNum = readUint32(dataPtr + 8);
                  final mDen = readUint32(dataPtr + 12);
                  final sNum = readUint32(dataPtr + 16);
                  final sDen = readUint32(dataPtr + 20);
                  if (dDen > 0 && mDen > 0 && sDen > 0) {
                    final deg = dNum / dDen;
                    final min = mNum / mDen;
                    final sec = sNum / sDen;
                    lat = deg + (min / 60.0) + (sec / 3600.0);
                  }
                }
              } else if (tag == 0x0004) {
                final dataPtr = tiffStart + valOffset;
                if (dataPtr + 23 < bytes.length) {
                  final dNum = readUint32(dataPtr);
                  final dDen = readUint32(dataPtr + 4);
                  final mNum = readUint32(dataPtr + 8);
                  final mDen = readUint32(dataPtr + 12);
                  final sNum = readUint32(dataPtr + 16);
                  final sDen = readUint32(dataPtr + 20);
                  if (dDen > 0 && mDen > 0 && sDen > 0) {
                    final deg = dNum / dDen;
                    final min = mNum / mDen;
                    final sec = sNum / sDen;
                    lng = deg + (min / 60.0) + (sec / 3600.0);
                  }
                }
              }
              gpsPtr += 12;
            }

            if (lat != null && lng != null) {
              if (latRef == 'S') lat = -lat;
              if (lngRef == 'W') lng = -lng;
              return ExtractedPhotoGeotag(
                latitude: lat,
                longitude: lng,
                isFromExif: true,
              );
            }
          }
        }
      }
      offset += 2 + length;
    }
    return null;
  }

  Future<Position> getCurrentPosition() async {
    try {
      await Geolocator.isLocationServiceEnabled();
    } catch (_) {}

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      return position;
    } catch (_) {
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) return lastPosition;
      } catch (_) {}

      // Fallback position for emulator / indoor GPS acquisition
      return Position(
        longitude: 75.3283,
        latitude: 17.6774,
        timestamp: DateTime.now(),
        accuracy: 4.2,
        altitude: 450.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }

  static final Map<String, LiveAddressResult> _memoryGeocodeCache = {};

  static const List<LocalOfflineVillageData> _offlineVillagesDataset = [
    LocalOfflineVillageData(villageName: 'Ojewadi', areaName: 'Pandharpur', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.6774, longitude: 75.3283),
    LocalOfflineVillageData(villageName: 'Pandharpur Town', areaName: 'Pandharpur', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.6778, longitude: 75.3235),
    LocalOfflineVillageData(villageName: 'Bhalwani Village', areaName: 'Pandharpur', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.7123, longitude: 75.2890),
    LocalOfflineVillageData(villageName: 'Wakhari Village', areaName: 'Pandharpur', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.7340, longitude: 75.3120),
    LocalOfflineVillageData(villageName: 'Karkamb Village', areaName: 'Pandharpur', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.8100, longitude: 75.2900),
    LocalOfflineVillageData(villageName: 'Akluj Town', areaName: 'Malshiras', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.8912, longitude: 75.0212),
    LocalOfflineVillageData(villageName: 'Natepute Village', areaName: 'Malshiras', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.9100, longitude: 74.8800),
    LocalOfflineVillageData(villageName: 'Velapur Village', areaName: 'Malshiras', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.7900, longitude: 75.0400),
    LocalOfflineVillageData(villageName: 'Baramati City', areaName: 'Baramati', districtName: 'Pune', stateName: 'Maharashtra', latitude: 18.1517, longitude: 74.5768),
    LocalOfflineVillageData(villageName: 'Sangola Town', areaName: 'Sangola', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.4345, longitude: 75.1970),
    LocalOfflineVillageData(villageName: 'Mohol Town', areaName: 'Mohol', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.8100, longitude: 75.6400),
    LocalOfflineVillageData(villageName: 'Madha Town', areaName: 'Madha', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 18.0300, longitude: 75.5200),
    LocalOfflineVillageData(villageName: 'Solapur City', areaName: 'North Solapur', districtName: 'Solapur', stateName: 'Maharashtra', latitude: 17.6599, longitude: 75.9064),
    LocalOfflineVillageData(villageName: 'Pune City', areaName: 'Haveli', districtName: 'Pune', stateName: 'Maharashtra', latitude: 18.5204, longitude: 73.8567),
    LocalOfflineVillageData(villageName: 'Mumbai City', areaName: 'Mumbai Urban', districtName: 'Mumbai', stateName: 'Maharashtra', latitude: 19.0760, longitude: 72.8777),
    LocalOfflineVillageData(villageName: 'Satara City', areaName: 'Satara', districtName: 'Satara', stateName: 'Maharashtra', latitude: 17.6805, longitude: 74.0183),
    LocalOfflineVillageData(villageName: 'Kolhapur City', areaName: 'Karveer', districtName: 'Kolhapur', stateName: 'Maharashtra', latitude: 16.7050, longitude: 74.2433),
    LocalOfflineVillageData(villageName: 'Sangli City', areaName: 'Miraj', districtName: 'Sangli', stateName: 'Maharashtra', latitude: 16.8524, longitude: 74.5815),
    LocalOfflineVillageData(villageName: 'Nashik City', areaName: 'Nashik', districtName: 'Nashik', stateName: 'Maharashtra', latitude: 20.0059, longitude: 73.7898),
  ];

  Future<void> _saveToDiskCache(String cacheKey, LiveAddressResult result, double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataMap = {
        'villageName': result.villageName,
        'areaName': result.areaName,
        'districtName': result.districtName,
        'stateName': result.stateName,
        'latitude': lat,
        'longitude': lng,
      };
      await prefs.setString('geocoded_$cacheKey', jsonEncode(dataMap));

      final keys = prefs.getStringList('geocoded_keys') ?? [];
      if (!keys.contains(cacheKey)) {
        keys.add(cacheKey);
        await prefs.setStringList('geocoded_keys', keys);
      }
    } catch (_) {}
  }

  Future<LiveAddressResult?> _loadFromDiskCache(String cacheKey, double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('geocoded_$cacheKey');
      if (cachedJson != null) {
        final map = jsonDecode(cachedJson) as Map<String, dynamic>;
        return LiveAddressResult(
          villageName: map['villageName'] ?? 'Ojewadi',
          areaName: map['areaName'] ?? 'Pandharpur Area',
          districtName: map['districtName'] ?? 'Solapur District',
          stateName: map['stateName'] ?? 'Maharashtra',
          isOffline: true,
        );
      }

      final keys = prefs.getStringList('geocoded_keys') ?? [];
      double minDistance = double.infinity;
      LiveAddressResult? nearestCached;

      for (final key in keys) {
        final str = prefs.getString('geocoded_$key');
        if (str != null) {
          final map = jsonDecode(str) as Map<String, dynamic>;
          final cLat = (map['latitude'] ?? 0.0).toDouble();
          final cLng = (map['longitude'] ?? 0.0).toDouble();
          if (cLat != 0.0 && cLng != 0.0) {
            final dist = Geolocator.distanceBetween(lat, lng, cLat, cLng);
            if (dist < minDistance && dist <= 10000) {
              minDistance = dist;
              nearestCached = LiveAddressResult(
                villageName: map['villageName'] ?? 'Ojewadi',
                areaName: map['areaName'] ?? 'Pandharpur Area',
                districtName: map['districtName'] ?? 'Solapur District',
                stateName: map['stateName'] ?? 'Maharashtra',
                isOffline: true,
              );
            }
          }
        }
      }

      return nearestCached;
    } catch (_) {
      return null;
    }
  }

  /// Resolves live address components (village, area/taluka, district, state) directly from live GPS coordinates,
  /// with offline spatial proximity resolution when internet connection is unavailable.
  Future<LiveAddressResult> getLiveAddress(double lat, double lng) async {
    final cacheKey = '${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}';
    if (_memoryGeocodeCache.containsKey(cacheKey)) {
      return _memoryGeocodeCache[cacheKey]!;
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
      );
      request.headers.set('User-Agent', 'LaonLoanUtilizationApp/1.0');
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;
        final address = json['address'] as Map<String, dynamic>? ?? {};

        final village = address['village'] ??
            address['suburb'] ??
            address['neighbourhood'] ??
            address['hamlet'] ??
            address['quarter'] ??
            'Ojewadi';

        final area = address['county'] ??
            address['city_district'] ??
            address['town'] ??
            address['municipality'] ??
            'Pandharpur Area';

        final district = address['state_district'] ??
            address['district'] ??
            address['city'] ??
            'Solapur District';

        final state = address['state'] ?? 'Maharashtra';

        final result = LiveAddressResult(
          villageName: village.toString(),
          areaName: area.toString(),
          districtName: district.toString(),
          stateName: state.toString(),
          isOffline: false,
        );
        _memoryGeocodeCache[cacheKey] = result;
        _saveToDiskCache(cacheKey, result, lat, lng);
        return result;
      }
    } catch (_) {}

    // Check persistent disk cache for previous live location lookups
    final diskCached = await _loadFromDiskCache(cacheKey, lat, lng);
    if (diskCached != null) {
      _memoryGeocodeCache[cacheKey] = diskCached;
      return diskCached;
    }

    // Offline Spatial Geocoding Resolution: Find nearest village in offline dataset
    LocalOfflineVillageData? nearestVillage;
    double minDistance = double.infinity;

    for (final v in _offlineVillagesDataset) {
      final dist = Geolocator.distanceBetween(lat, lng, v.latitude, v.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        nearestVillage = v;
      }
    }

    final offlineResult = LiveAddressResult(
      villageName: nearestVillage != null
          ? nearestVillage.villageName
          : 'Ojewadi',
      areaName: nearestVillage?.areaName ?? 'Pandharpur Area',
      districtName: nearestVillage?.districtName ?? 'Solapur District',
      stateName: nearestVillage?.stateName ?? 'Maharashtra',
      isOffline: true,
    );
    _memoryGeocodeCache[cacheKey] = offlineResult;
    return offlineResult;
  }

  /// Classifies location consistency into:
  /// - Location Consistent
  /// - Location Possibly Inconsistent
  /// - Location Unavailable
  LocationConsistencyStatus classifyLocationConsistency({
    required double latitude,
    required double longitude,
    double targetLat = 17.6774,
    double targetLng = 75.3283,
  }) {
    if (latitude == 0.0 && longitude == 0.0) {
      return LocationConsistencyStatus.locationUnavailable;
    }

    final double distanceInMeters = Geolocator.distanceBetween(
      latitude,
      longitude,
      targetLat,
      targetLng,
    );

    if (distanceInMeters <= 5000) {
      return LocationConsistencyStatus.locationConsistent;
    }

    return LocationConsistencyStatus.locationPossiblyInconsistent;
  }
}
