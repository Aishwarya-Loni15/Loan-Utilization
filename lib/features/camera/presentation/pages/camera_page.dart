import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/camera_provider.dart';
import '../widgets/camera_controls.dart';
import '../widgets/camera_preview.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final notifier = ref.read(cameraNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Utilization Evidence'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (cameraState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.redAccent,
                child: Text(
                  cameraState.errorMessage!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: CameraPreviewWidget(
                imageFile: cameraState.capturedFile,
                onCaptureTap: () => notifier.capturePhoto(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.black,
              child: CameraControlsWidget(
                imageFile: cameraState.capturedFile,
                isLoading: cameraState.isLoading,
                onCapture: () => notifier.capturePhoto(),
                onGallery: () => notifier.pickFromGallery(),
                onRetake: () => notifier.retake(),
                onConfirm: () {
                  if (cameraState.capturedFile != null) {
                    context.pop<File>(cameraState.capturedFile);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
