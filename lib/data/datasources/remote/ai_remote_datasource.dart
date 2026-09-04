import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/firebase_exception_handler.dart';
import '../../models/ai_analysis_model.dart';

class AiRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  AiRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  Future<AiAnalysisModel> runAiAnalysisCloudFunction(String submissionId) async {
    try {
      final callable = _functions.httpsCallable('analyzeSubmission');
      final result = await callable.call({'submissionId': submissionId});
      final data = Map<String, dynamic>.from(result.data as Map);
      return AiAnalysisModel.fromMap(data, data['analysisId'] ?? 'ai_$submissionId');
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  Future<AiAnalysisModel?> getAiAnalysis(String submissionId) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.aiAnalysesCollection).doc(submissionId).get();
      if (!doc.exists || doc.data() == null) return null;
      return AiAnalysisModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }
}
