import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mock_database_service.dart';

class FirebaseDatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Seeds all 13 database collections into Firebase Firestore.
  Future<void> seedAllCollections() async {
    debugPrint('');
    debugPrint('══════════════════════════════════════════════');
    debugPrint('🚀 LOANLENS FIRESTORE DATABASE SEEDER');
    debugPrint('══════════════════════════════════════════════');

    try {
      // 1. Ensure Firebase Auth Session
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        try {
          final cred = await _auth.signInAnonymously();
          currentUser = cred.user;
          debugPrint('🔑 Anonymous auth session created for database seeding: ${currentUser?.uid}');
        } catch (e) {
          debugPrint('ℹ️ Unauthenticated seeding mode (Anonymous Auth disabled): $e');
        }
      } else {
        debugPrint('👤 Authenticated User UID: ${currentUser.uid}');
      }

      final mock = MockDatabaseService();
      int successCount = 0;

      // 1. States
      try {
        debugPrint('📍 [1/13] Seeding states...');
        for (final state in mock.states) {
          await _firestore.collection('states').doc(state.stateId).set({
            'stateId': state.stateId,
            'name': state.name,
            'code': state.code,
          }, SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [1/13] states seeded.');
      } catch (e) {
        debugPrint('⚠️ [1/13] states failed: $e');
      }

      // 2. Districts
      try {
        debugPrint('📍 [2/13] Seeding districts...');
        for (final district in mock.districts) {
          await _firestore.collection('districts').doc(district.districtId).set({
            'districtId': district.districtId,
            'stateId': district.stateId,
            'name': district.name,
          }, SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [2/13] districts seeded.');
      } catch (e) {
        debugPrint('⚠️ [2/13] districts failed: $e');
      }

      // 3. Talukas
      try {
        debugPrint('📍 [3/13] Seeding talukas...');
        for (final taluka in mock.talukas) {
          await _firestore.collection('talukas').doc(taluka.talukaId).set({
            'talukaId': taluka.talukaId,
            'districtId': taluka.districtId,
            'name': taluka.name,
          }, SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [3/13] talukas seeded.');
      } catch (e) {
        debugPrint('⚠️ [3/13] talukas failed: $e');
      }

      // 4. Villages
      try {
        debugPrint('📍 [4/13] Seeding villages...');
        for (final village in mock.villages) {
          await _firestore.collection('villages').doc(village.villageId).set({
            'villageId': village.villageId,
            'talukaId': village.talukaId,
            'name': village.name,
          }, SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [4/13] villages seeded.');
      } catch (e) {
        debugPrint('⚠️ [4/13] villages failed: $e');
      }

      // 5. Banks
      try {
        debugPrint('🏦 [5/13] Seeding banks...');
        for (final bank in mock.banks) {
          await _firestore.collection('banks').doc(bank.id).set(bank.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [5/13] banks seeded.');
      } catch (e) {
        debugPrint('⚠️ [5/13] banks failed: $e');
      }

      // 6. Users
      try {
        debugPrint('👥 [6/13] Seeding users...');
        for (final user in mock.users) {
          await _firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [6/13] users seeded.');
      } catch (e) {
        debugPrint('⚠️ [6/13] users failed: $e');
      }

      // 7. Loans
      try {
        debugPrint('💰 [7/13] Seeding loans...');
        for (final loan in mock.loans) {
          await _firestore.collection('loans').doc(loan.loanId).set(loan.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [7/13] loans seeded.');
      } catch (e) {
        debugPrint('⚠️ [7/13] loans failed: $e');
      }

      // 8. QR Linking Tokens
      try {
        debugPrint('🔑 [8/13] Seeding qr_linking_tokens...');
        for (final token in mock.qrTokens) {
          await _firestore.collection('qr_linking_tokens').doc(token.tokenId).set(token.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [8/13] qr_linking_tokens seeded.');
      } catch (e) {
        debugPrint('⚠️ [8/13] qr_linking_tokens failed: $e');
      }

      // 9. Utilization Submissions
      try {
        debugPrint('📸 [9/13] Seeding utilization_submissions...');
        for (final sub in mock.submissions) {
          await _firestore.collection('utilization_submissions').doc(sub.submissionId).set(sub.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [9/13] utilization_submissions seeded.');
      } catch (e) {
        debugPrint('⚠️ [9/13] utilization_submissions failed: $e');
      }

      // 10. AI Analyses
      try {
        debugPrint('🤖 [10/13] Seeding ai_analyses...');
        for (final ai in mock.aiAnalyses) {
          await _firestore.collection('ai_analyses').doc(ai.analysisId).set(ai.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [10/13] ai_analyses seeded.');
      } catch (e) {
        debugPrint('⚠️ [10/13] ai_analyses failed: $e');
      }

      // 11. Audit Logs
      try {
        debugPrint('📝 [11/13] Seeding audit_logs...');
        for (final log in mock.auditLogs) {
          await _firestore.collection('audit_logs').doc(log.logId).set(log.toMap(), SetOptions(merge: true));
        }
        successCount++;
        debugPrint('✅ [11/13] audit_logs seeded.');
      } catch (e) {
        debugPrint('⚠️ [11/13] audit_logs failed: $e');
      }

      // 12. Notifications
      try {
        debugPrint('🔔 [12/13] Seeding notifications...');
        await _firestore.collection('notifications').doc('notif_001').set({
          'notificationId': 'notif_001',
          'userId': 'user_ben_01',
          'title': 'Loan Linked Successfully',
          'message': 'Your offline loan account LN20260001 has been linked by Bank Manager Amitabh Deshmukh.',
          'type': 'loanLinked',
          'relatedLoanId': 'LN20260001',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        // 12b. Beneficiaries
        await _firestore.collection('beneficiaries').doc('ben_4912').set({
          'beneficiaryId': 'ben_4912',
          'userId': 'user_ben_01',
          'name': 'Ramesh Vitthal Patil',
          'phone': '+919850123456',
          'address': 'Plot 42, Kavathe Village',
          'state': 'Maharashtra',
          'district': 'Solapur',
          'taluka': 'Pandharpur',
          'village': 'Kavathe',
          'createdAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        successCount++;
        debugPrint('✅ [12/13] notifications & beneficiaries seeded.');
      } catch (e) {
        debugPrint('⚠️ [12/13] notifications failed: $e');
      }

      // 13. Analytics
      try {
        debugPrint('📊 [13/13] Seeding analytics...');
        await _firestore.collection('analytics').doc('district_solapur_metrics').set({
          'docId': 'district_solapur_metrics',
          'districtId': 'dst_sol',
          'districtName': 'Solapur',
          'totalLoansCount': 1420,
          'totalDisbursedAmount': 142000000.0,
          'totalUtilizedAmount': 118000000.0,
          'averageUtilizationPercentage': 83.1,
          'pendingVerificationCount': 42,
          'verifiedSuccessCount': 1378,
          'flaggedFraudCount': 3,
          'lastUpdatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        successCount++;
        debugPrint('✅ [13/13] analytics seeded.');
      } catch (e) {
        debugPrint('⚠️ [13/13] analytics failed: $e');
      }

      debugPrint('');
      debugPrint('══════════════════════════════════════════════');
      debugPrint('🎉 SEEDER COMPLETED: $successCount / 13 collections seeded.');
      debugPrint('══════════════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('❌ DATABASE SEEDER EXCEPTION: $e\n$stackTrace');
    }
  }
}
