import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../errors/app_exception.dart';

class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<File?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw AppException(
        message: 'Failed to capture image: ${e.toString()}',
        code: 'camera_capture_error',
      );
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw AppException(
        message: 'Failed to pick image from gallery: ${e.toString()}',
        code: 'gallery_pick_error',
      );
    }
  }
}
