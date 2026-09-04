import 'dart:io';
import 'package:flutter/material.dart';

class CameraControlsWidget extends StatelessWidget {
  final File? imageFile;
  final bool isLoading;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  const CameraControlsWidget({
    super.key,
    required this.imageFile,
    required this.isLoading,
    required this.onCapture,
    required this.onGallery,
    required this.onRetake,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (imageFile != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              minimumSize: const Size(130, 48),
            ),
            onPressed: onRetake,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retake'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(130, 48),
            ),
            onPressed: onConfirm,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirm'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 32),
          onPressed: onGallery,
          tooltip: 'Pick from Gallery',
        ),
        GestureDetector(
          onTap: onCapture,
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }
}
