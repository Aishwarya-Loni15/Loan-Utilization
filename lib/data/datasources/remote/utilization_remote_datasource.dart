import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/firebase_exception_handler.dart';
import '../../models/utilization_submission_model.dart';

class UtilizationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UtilizationRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<UtilizationSubmissionModel>> getSubmissions() async {
    try {
      final snapshot = await _firestore.collection(FirebaseConstants.submissionsCollection).get().timeout(const Duration(seconds: 3));
      return snapshot.docs.map((doc) => UtilizationSubmissionModel.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<UtilizationSubmissionModel>> getSubmissionsForBeneficiary(String beneficiaryId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.submissionsCollection)
          .where('beneficiaryId', isEqualTo: beneficiaryId)
          .get();
      return snapshot.docs.map((doc) => UtilizationSubmissionModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  Future<UtilizationSubmissionModel?> getSubmissionById(String id) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.submissionsCollection).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return UtilizationSubmissionModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  Future<String> uploadEvidenceFile(File file, String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  Future<void> createSubmission(UtilizationSubmissionModel submission) async {
    try {
      await _firestore
          .collection(FirebaseConstants.submissionsCollection)
          .doc(submission.submissionId)
          .set(submission.toMap());
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }
}
