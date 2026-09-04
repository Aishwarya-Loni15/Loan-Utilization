import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/core/widgets/app_button.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/location/providers/location_provider.dart';
import '../widgets/location_info_card.dart';
import '../widgets/location_map.dart';

class LocationCapturePage extends ConsumerStatefulWidget {
  const LocationCapturePage({super.key});

  @override
  ConsumerState<LocationCapturePage> createState() => _LocationCapturePageState();
}

class _LocationCapturePageState extends ConsumerState<LocationCapturePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(locationCaptureNotifierProvider.notifier).captureGPSLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationCaptureNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Geotag Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automatic Location Lock',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manual GPS coordinates entry is strictly disabled for security compliance.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 20),
              LocationMapWidget(locationData: state.locationData),
              const SizedBox(height: 20),
              if (state.isLoading)
                const LoadingWidget(message: 'Acquiring high-accuracy satellite GPS coordinates...')
              else if (state.errorMessage != null) ...[
                AppErrorWidget(
                  message: state.errorMessage!,
                  onRetry: () {
                    ref.read(locationCaptureNotifierProvider.notifier).captureGPSLocation();
                  },
                ),
              ] else if (state.locationData != null) ...[
                LocationInfoCardWidget(locationData: state.locationData!),
                const Spacer(),
                AppButton(
                  text: 'Confirm Geotag Coordinates',
                  onPressed: () {
                    context.pop<LocationCaptureData>(state.locationData);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
