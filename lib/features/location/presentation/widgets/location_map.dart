import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/location/providers/location_provider.dart';

class LocationMapWidget extends StatelessWidget {
  final LocationCaptureData? locationData;

  const LocationMapWidget({
    super.key,
    required this.locationData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.map_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          if (locationData != null) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'GPS Geotag Locked',
                      style: TextStyle(
                        color: Colors.greenAccent[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Center(
              child: Text(
                'Waiting for satellite location lock...',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
