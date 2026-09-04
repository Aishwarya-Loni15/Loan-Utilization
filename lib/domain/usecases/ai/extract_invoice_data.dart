import '../../repositories/ai_repository.dart';

class ExtractInvoiceData {
  final AiRepository repository;

  ExtractInvoiceData(this.repository);

  Future<Map<String, dynamic>> call(String documentUrl) async {
    return await repository.extractInvoiceData(documentUrl);
  }
}
