import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/features/location/providers/location_provider.dart';

class LocationInfoCardWidget extends StatelessWidget {
  final LocationCaptureData locationData;

  const LocationInfoCardWidget({
    super.key,
    required this.locationData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Geotag Data Verification',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Auto-Captured',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRow('Live Latitude', locationData.latitude.toStringAsFixed(6)),
          const SizedBox(height: 6),
          _buildRow('Live Longitude', locationData.longitude.toStringAsFixed(6)),
          if (locationData.villageName != null && locationData.villageName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildRow('Live Village', locationData.villageName!),
          ],
          if (locationData.areaName != null && locationData.areaName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildRow('Live Area', locationData.areaName!),
          ],
          if (locationData.districtName != null && locationData.districtName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildRow('Live District', locationData.districtName!),
          ] else if (locationData.cityName != null && locationData.cityName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildRow('Live City / District', locationData.cityName!),
          ],
          const SizedBox(height: 6),
          _buildRow('Accuracy Margin', '±${locationData.accuracy.toStringAsFixed(1)} meters'),
          const SizedBox(height: 6),
          _buildRow('Timestamp', AppDateUtils.formatDateTime(locationData.timestamp)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
