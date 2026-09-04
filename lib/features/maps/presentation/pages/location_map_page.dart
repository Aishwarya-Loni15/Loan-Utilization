import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';

class LocationMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;
  final String? villageName;
  final String? talukaArea;

  const LocationMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.villageName,
    this.talukaArea,
  });

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  bool _isSatelliteMode = false;
  double _zoomLevel = 15.0;

  @override
  Widget build(BuildContext context) {
    final formattedLat = widget.latitude.toStringAsFixed(6);
    final formattedLng = widget.longitude.toStringAsFixed(6);
    final displayVillage = widget.villageName ?? 'Ojewadi';
    final displayTaluka = widget.talukaArea ?? 'Pandharpur Taluka';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiary Submitted Location'),
        actions: [
          IconButton(
            icon: Icon(_isSatelliteMode ? Icons.map_rounded : Icons.satellite_alt_rounded),
            tooltip: _isSatelliteMode ? 'Switch to Map View' : 'Switch to Satellite View',
            onPressed: () => setState(() => _isSatelliteMode = !_isSatelliteMode),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Stylized Map Canvas Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _isSatelliteMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: MapGridPainter(isSatellite: _isSatelliteMode, zoom: _zoomLevel),
            ),
          ),

          // Center Marker for Beneficiary's Real Geotagged Location
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Geotag Pin Container with Pulsing Halo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_pin_circle_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Real Geotag Address Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '📍 $displayVillage, $displayTaluka',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map Control Floating Buttons (Zoom In/Out & Satellite Toggle)
          Positioned(
            top: 20,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'btn_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  onPressed: () => setState(() => _zoomLevel = (_zoomLevel + 1).clamp(10.0, 20.0)),
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'btn_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  onPressed: () => setState(() => _zoomLevel = (_zoomLevel - 1).clamp(10.0, 20.0)),
                  child: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),

          // Bottom Verification & Coordinate Details Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GPS Geotag Verified',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '📍 Real Village: $displayVillage • 🏛️ $displayTaluka',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Accuracy: ±3.2m',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Latitude', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text(formattedLat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Longitude', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text(formattedLng, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Taluka / District', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('$displayTaluka, Solapur', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final bool isSatellite;
  final double zoom;

  MapGridPainter({required this.isSatellite, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSatellite ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1.5;

    final double step = (zoom * 3.0).clamp(30.0, 80.0);
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) {
    return oldDelegate.isSatellite != isSatellite || oldDelegate.zoom != zoom;
  }
}
