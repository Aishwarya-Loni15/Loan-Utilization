import 'dart:io';
import '../../repositories/utilization_repository.dart';

class UploadEvidence {
  final UtilizationRepository repository;

  UploadEvidence(this.repository);

  Future<String> call(File file, String folderPath) async {
    return await repository.uploadFile(file, folderPath);
  }
}
