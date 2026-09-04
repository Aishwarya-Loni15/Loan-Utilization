import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

class CameraState {
  final File? capturedFile;
  final bool isLoading;
  final String? errorMessage;

  const CameraState({
    this.capturedFile,
    this.isLoading = false,
    this.errorMessage,
  });

  CameraState copyWith({
    File? capturedFile,
    bool? isLoading,
    String? errorMessage,
    bool clearFile = false,
  }) {
    return CameraState(
      capturedFile: clearFile ? null : (capturedFile ?? this.capturedFile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final cameraNotifierProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  return CameraNotifier(cameraService);
});

class CameraNotifier extends StateNotifier<CameraState> {
  final CameraService _cameraService;

  CameraNotifier(this._cameraService) : super(const CameraState());

  Future<void> capturePhoto() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final file = await _cameraService.captureImage();
      if (file != null) {
        state = state.copyWith(capturedFile: file, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('AppException: ', ''),
      );
    }
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final file = await _cameraService.pickFromGallery();
      if (file != null) {
        state = state.copyWith(capturedFile: file, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('AppException: ', ''),
      );
    }
  }

  void retake() {
    state = state.copyWith(clearFile: true, errorMessage: null);
  }
}
