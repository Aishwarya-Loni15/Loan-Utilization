import '../../repositories/ai_repository.dart';

class DetectObjects {
  final AiRepository repository;

  DetectObjects(this.repository);

  Future<List<String>> call(String imageUrl) async {
    return await repository.detectObjects(imageUrl);
  }
}
