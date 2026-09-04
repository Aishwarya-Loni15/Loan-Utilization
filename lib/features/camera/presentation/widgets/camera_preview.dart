import 'dart:io';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onCaptureTap;

  const CameraPreviewWidget({
    super.key,
    required this.imageFile,
    required this.onCaptureTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            imageFile!,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Preview Captured',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 48),
                onPressed: onCaptureTap,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to Open Camera shutter',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
