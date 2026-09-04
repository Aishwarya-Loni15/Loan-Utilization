import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class WatermarkMetadata {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;
  final String loanId;
  final String beneficiaryId;
  final bool isOnline;
  final String gpsStatus;
  final String villageName;

  const WatermarkMetadata({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
    required this.loanId,
    required this.beneficiaryId,
    required this.isOnline,
    this.gpsStatus = 'GNSS Satellite',
    this.villageName = 'Ojewadi',
  });
}

class PhotoWatermarkService {
  static final PhotoWatermarkService _instance = PhotoWatermarkService._internal();
  factory PhotoWatermarkService() => _instance;
  PhotoWatermarkService._internal();

  /// Stamps a visible local watermark banner onto the captured image file.
  /// Operates 100% locally on device storage without online API calls.
  Future<File> addWatermark(File originalPhoto, WatermarkMetadata metadata) async {
    try {
      final bytes = await originalPhoto.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        return originalPhoto;
      }

      // Ensure orientation is normalized
      image = img.bakeOrientation(image);

      final width = image.width;
      final height = image.height;

      // Draw semi-transparent dark banner at bottom of image
      final bannerHeight = (height * 0.18).clamp(120.0, 320.0).toInt();
      final bannerTop = height - bannerHeight;

      // Fill semi-transparent black rectangle
      img.fillRect(
        image,
        x1: 0,
        y1: bannerTop,
        x2: width,
        y2: height,
        color: img.ColorRgba8(0, 0, 0, 200),
      );

      final dateStr = DateFormat('dd-MM-yyyy').format(metadata.timestamp);
      final timeStr = DateFormat('hh:mm:ss a').format(metadata.timestamp);
      final latStr = metadata.latitude.toStringAsFixed(6);
      final lngStr = metadata.longitude.toStringAsFixed(6);
      final accStr = '${metadata.accuracy.toStringAsFixed(1)} m';
      final altStr = '${metadata.altitude.toStringAsFixed(1)} m';
      final netStr = metadata.isOnline ? 'Online' : 'Offline';

      // Draw watermark text lines using built-in font
      final font = img.arial24;

      final lines = [
        'LoanLens - Loan Utilization Proof',
        'Latitude: $latStr° N  |  Longitude: $lngStr° E',
        'Village: ${metadata.villageName}  |  Accuracy: $accStr',
        'Altitude: $altStr  |  Date: $dateStr  |  Time: $timeStr',
        'Loan ID: ${metadata.loanId}  |  Beneficiary ID: ${metadata.beneficiaryId}',
        'GPS: ${metadata.gpsStatus}  |  Network: $netStr',
      ];

      int yOffset = bannerTop + 12;
      for (int i = 0; i < lines.length; i++) {
        img.drawString(
          image,
          lines[i],
          font: font,
          x: 20,
          y: yOffset,
          color: i == 0 ? img.ColorRgba8(255, 215, 0, 255) : img.ColorRgba8(255, 255, 255, 255),
        );
        yOffset += 28;
        if (yOffset >= height - 10) break;
      }

      // Encode watermarked image back to JPEG bytes
      final watermarkedBytes = img.encodeJpg(image, quality: 88);

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'loanlens_geotag_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final watermarkedFile = File('${appDir.path}/$fileName');
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      return watermarkedFile;
    } catch (_) {
      // Return original photo fallback if watermark processing fails
      return originalPhoto;
    }
  }
}
