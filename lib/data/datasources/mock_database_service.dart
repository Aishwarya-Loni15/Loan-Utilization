import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';
import '../models/utilization_submission_model.dart';
import '../models/ai_analysis_model.dart';
import '../models/location_models.dart';
import '../models/bank_model.dart';
import '../models/audit_log_model.dart';
import '../models/qr_linking_token_model.dart';

import '../../core/enums/user_role.dart';
import '../../core/enums/loan_status.dart';
import '../../core/enums/submission_status.dart';
import '../../core/enums/risk_level.dart';

class MockDatabaseService {
  static final MockDatabaseService _instance = MockDatabaseService._internal();
  factory MockDatabaseService() => _instance;
  MockDatabaseService._internal() {
    _initSampleData();
    loadPersistedData();
  }

  final List<UserModel> users = [];
  final List<LoanModel> loans = [];
  final List<UtilizationSubmissionModel> submissions = [];
  final List<AiAnalysisModel> aiAnalyses = [];
  final List<StateModel> states = [];
  final List<DistrictModel> districts = [];
  final List<TalukaModel> talukas = [];
  final List<VillageModel> villages = [];
  final List<BankModel> banks = [];
  final List<AuditLogModel> auditLogs = [];
  final List<QrLinkingTokenModel> qrTokens = [];

  bool _isLoaded = false;

  Future<void> loadPersistedData() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final subsJson = prefs.getString('saved_submissions_json');
      if (subsJson != null && subsJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(subsJson);
        final loaded = list.map((item) => UtilizationSubmissionModel.fromMap(Map<String, dynamic>.from(item as Map), (item['submissionId'] ?? '').toString())).toList();
        for (final sub in loaded) {
          submissions.removeWhere((s) => s.submissionId == sub.submissionId);
          submissions.insert(0, sub);
        }
      }

      final aiJson = prefs.getString('saved_ai_analyses_json');
      if (aiJson != null && aiJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(aiJson);
        final loaded = list.map((item) => AiAnalysisModel.fromMap(Map<String, dynamic>.from(item as Map), (item['analysisId'] ?? '').toString())).toList();
        for (final ai in loaded) {
          aiAnalyses.removeWhere((a) => a.submissionId == ai.submissionId);
          aiAnalyses.insert(0, ai);
        }
      }
      _isLoaded = true;
    } catch (_) {}
  }

  Future<void> savePersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subsList = submissions.map((s) => s.toMap()).toList();
      await prefs.setString('saved_submissions_json', jsonEncode(subsList));

      final aiList = aiAnalyses.map((a) => a.toMap()).toList();
      await prefs.setString('saved_ai_analyses_json', jsonEncode(aiList));
    } catch (_) {}
  }


  void _initSampleData() {
    // Locations
    states.add(StateModel(stateId: 'st_mah', name: 'Maharashtra', code: 'MH'));
    districts.addAll([
      DistrictModel(districtId: 'dst_sol', stateId: 'st_mah', name: 'Solapur'),
      DistrictModel(districtId: 'dst_pun', stateId: 'st_mah', name: 'Pune'),
      DistrictModel(districtId: 'dst_nas', stateId: 'st_mah', name: 'Nashik'),
    ]);
    talukas.addAll([
      TalukaModel(talukaId: 'tlk_pan', districtId: 'dst_sol', name: 'Pandharpur'),
      TalukaModel(talukaId: 'tlk_mal', districtId: 'dst_sol', name: 'Malshiras'),
      TalukaModel(talukaId: 'tlk_bar', districtId: 'dst_pun', name: 'Baramati'),
    ]);
    villages.addAll([
      VillageModel(villageId: 'vlg_kav', talukaId: 'tlk_pan', name: 'Kavathe'),
      VillageModel(villageId: 'vlg_bha', talukaId: 'tlk_pan', name: 'Bhalwani'),
      VillageModel(villageId: 'vlg_nat', talukaId: 'tlk_mal', name: 'Natepute'),
    ]);

    // Banks
    banks.addAll([
      const BankModel(id: 'bnk_sbi_sol', name: 'State Bank of India', branchName: 'Pandharpur Main', ifscCode: 'SBIN0000445', district: 'Solapur', state: 'Maharashtra'),
      const BankModel(id: 'bnk_mah_pun', name: 'Bank of Maharashtra', branchName: 'Baramati Main', ifscCode: 'MAHB0000122', district: 'Pune', state: 'Maharashtra'),
    ]);

    // Users
    users.addAll([
      UserModel(
        uid: 'user_admin_01',
        email: 'admin@loanlens.gov.in',
        name: 'Rajesh Sharma (Admin)',
        phone: '+919876543210',
        role: UserRole.admin,
        state: 'st_mah',
        district: 'dst_sol',
        taluka: 'tlk_pan',
        village: 'vlg_kav',
        address: 'HQ, Mumbai',
      ),
      UserModel(
        uid: 'user_officer_sol',
        email: 'officer.solapur@loanlens.gov.in',
        name: 'Priya Kulkarni',
        phone: '+919822110044',
        role: UserRole.stateOfficer,
        state: 'st_mah',
        district: 'dst_sol',
        taluka: 'tlk_pan',
        village: 'vlg_kav',
        address: 'District Collectorate, Solapur',
      ),
      UserModel(
        uid: 'user_bank_sbi',
        email: 'manager.sbi@bank.co.in',
        name: 'Amitabh Deshmukh',
        phone: '+919422003311',
        role: UserRole.bankManager,
        state: 'st_mah',
        district: 'dst_sol',
        taluka: 'tlk_pan',
        village: 'vlg_kav',
        address: 'SBI Branch, Pandharpur',
        bankId: 'bnk_sbi_sol',
      ),
      UserModel(
        uid: 'user_ben_01',
        email: 'ramesh.farmer@gmail.com',
        name: 'Ramesh Vitthal Patil',
        phone: '+919850123456',
        role: UserRole.beneficiary,
        state: 'st_mah',
        district: 'dst_sol',
        taluka: 'tlk_pan',
        village: 'vlg_kav',
        address: 'Gat No. 142, Kavathe Village, Pandharpur',
      ),
    ]);

    // Loans
    loans.addAll([
      LoanModel(
        loanId: 'loan_agri_201',
        beneficiaryId: 'user_ben_01',
        beneficiaryName: 'Ramesh Vitthal Patil',
        beneficiaryMobile: '+919850123456',
        beneficiaryEmail: 'ramesh.farmer@gmail.com',
        bankId: 'bnk_sbi_sol',
        bankManagerId: 'user_bank_sbi',
        schemeName: 'PM-KUSUM Solar Tractor Scheme',
        purpose: 'Purchase of 45HP Agricultural Equipment & Solar Sprayer',
        category: 'Agricultural Machinery',
        sanctionedAmount: 200000.0,
        disbursedAmount: 200000.0,
        utilizedAmount: 185000.0,
        remainingAmount: 15000.0,
        utilizationPercentage: 92.5,
        disbursementDate: DateTime.now().subtract(const Duration(days: 14)),
        expectedUtilizationDate: DateTime.now().add(const Duration(days: 30)),
        status: LoanStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        isLinked: true,
      ),
    ]);

    // Submissions & AI Analysis
    final sub1Id = 'sub_001_verified';
    submissions.add(
      UtilizationSubmissionModel(
        submissionId: sub1Id,
        loanId: 'loan_agri_201',
        beneficiaryId: 'user_ben_01',
        amountSpent: 185000.0,
        description: 'Purchased 45HP Tractor Sprayer from ABC Agro Machinery, Pandharpur.',
        photoUrls: ['https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600'],
        videoUrls: [],
        documentUrls: ['https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'],
        latitude: 17.6774,
        longitude: 75.3283,
        locationAccuracy: 4.2,
        capturedAt: DateTime.now().subtract(const Duration(days: 2)),
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: SubmissionStatus.approved,
        aiScore: 94.0,
        riskLevel: RiskLevel.low,
        reviewedBy: 'Priya Kulkarni (State Officer)',
        reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    aiAnalyses.add(
      AiAnalysisModel(
        analysisId: 'ai_ana_001',
        submissionId: sub1Id,
        aiScore: 94.0,
        riskLevel: RiskLevel.low,
        purposeMatchScore: 96.0,
        invoiceMatchScore: 95.0,
        imageMatchScore: 92.0,
        locationScore: 98.0,
        duplicateScore: 100.0,
        extractedInvoiceAmount: 185000.0,
        detectedObjects: ['Tractor Equipment', 'Solar Power Sprayer', 'Agro Machinery'],
        detectedText: 'ABC AGRO EQUIPMENT PANDHARPUR INVOICE #9822 AMOUNT: RS 1,85,000',
        reasons: [
          'GPS Location matches registered beneficiary agricultural land (Pandharpur)',
          'Invoice amount (Rs 1,85,000) matches submitted claim exactly',
          'Detected image contains authentic agricultural machinery matching PM-KUSUM purpose',
          'No duplicate media hash detected in national database',
        ],
        analyzedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );

    // Audit logs
    auditLogs.addAll([
      AuditLogModel(
        logId: 'log_001',
        userId: 'user_ben_01',
        role: 'BENEFICIARY',
        action: 'SUBMISSION_CREATED',
        targetId: sub1Id,
        description: 'Beneficiary uploaded evidence for loan loan_agri_201',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AuditLogModel(
        logId: 'log_002',
        userId: 'SYSTEM_AI',
        role: 'AI_ENGINE',
        action: 'AI_ANALYSIS_COMPLETED',
        targetId: sub1Id,
        description: 'AI computed low risk score 94/100',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }
}
