enum SystemReportType {
  loanUtilization('Loan Utilization Report', 'Detailed analysis of capital disbursement vs verified utilization proofs across all schemes.'),
  verificationStatus('Verification Status Report', 'Complete breakdown of pending, approved, rejected, and resubmission-required claims.'),
  suspiciousCases('Suspicious Cases Report', 'Audit log of high-risk submissions, PURPOSE_MISMATCH flags, and distance inconsistencies.'),
  districtStatistics('District-Wise Statistics Report', 'Aggregated district & taluka-level loan distribution and completion metrics.'),
  bankStatistics('Bank-Wise Statistics Report', 'Branch-level performance, verification speed, and rejection rates across partner banks.'),
  beneficiaryHistory('Beneficiary-Wise History Report', 'Full audit trail of beneficiary applications, QR linking, and proof uploads.');

  final String title;
  final String description;

  const SystemReportType(this.title, this.description);
}

class ReportGeneratorService {
  String generateCsvReport(SystemReportType type) {
    final now = DateTime.now().toIso8601String();

    switch (type) {
      case SystemReportType.loanUtilization:
        return '''
"Loan ID","Beneficiary Name","Scheme","Sanctioned Amount (INR)","Verified Amount (INR)","Utilization Rate","Status","Generated At"
"LN20260001","Ramesh Vitthal Patil","PM-KUSUM Solar Tractor",185000,185000,"100.0%","APPROVED","$now"
"LN20260002","Suresh Tukaram Pawar","Drip Irrigation Setup",120000,0,"0.0%","PENDING","$now"
"LN20260003","Ganesh Dnyaneshwar Shinde","Dairy Cold Chain Storage",350000,350000,"100.0%","APPROVED","$now"
"LN20260004","Anita Vilas More","Polyhouse Horticulture Unit",250000,0,"0.0%","RESUBMISSION_REQUIRED","$now"
''';

      case SystemReportType.verificationStatus:
        return '''
"Submission ID","Loan ID","Beneficiary","AI Status","Officer Status","Submitted Date","Officer Remarks","Generated At"
"sub_001_verified","LN20260001","Ramesh Vitthal Patil","PURPOSE_MATCH","APPROVED","2026-08-10","Verified on site by BM Amitabh","$now"
"sub_002_flagged","LN20260002","Suresh Tukaram Pawar","PURPOSE_MISMATCH","REJECTED","2026-08-11","Rejection: Smartwatch image uploaded for farm equipment","$now"
"sub_003_resubmit","LN20260004","Anita Vilas More","PURPOSE_MATCH","RESUBMISSION_REQUIRED","2026-08-11","Request: Clearer invoice document required","$now"
''';

      case SystemReportType.suspiciousCases:
        return '''
"Risk Flag ID","Loan ID","Beneficiary","Detected Issue","Risk Level","Location Consistency","AI Score","Generated At"
"RISK-901","LN20260002","Suresh Tukaram Pawar","PURPOSE_MISMATCH","HIGH","Location Consistent",12.5,"$now"
"RISK-902","LN20260005","Vijay Baburao Kadam","Distance Boundary > 25km","MEDIUM","Location Possibly Inconsistent",64.0,"$now"
''';

      case SystemReportType.districtStatistics:
        return '''
"District","Taluka","Village","Total Loans","Disbursed Outlay (INR)","Approved Count","Pending Count","Generated At"
"Solapur","Pandharpur","Kavathe",14,2450000,10,4,"$now"
"Solapur","Pandharpur","Bhalwani",8,1200000,6,2,"$now"
"Solapur","Malshiras","Akluj",18,3200000,15,3,"$now"
''';

      case SystemReportType.bankStatistics:
        return '''
"Bank Name","Branch Name","Branch Manager","Total Loans","Approved Claims","Rejection Rate","Avg Audit Hours","Generated At"
"State Bank of India","Solapur Main","Amitabh Deshmukh",42,38,"4.7%",2.4,"$now"
"Bank of Baroda","Pandharpur","Sunita Kulkarni",28,24,"7.1%",3.1,"$now"
"Maharashtra Gramin Bank","Malshiras","Rajesh Shinde",35,30,"5.7%",1.8,"$now"
''';

      case SystemReportType.beneficiaryHistory:
        return '''
"Beneficiary ID","Name","Mobile","Linked Loan","Sanction Date","Submission Count","Current Status","Generated At"
"BEN-4912","Ramesh Vitthal Patil","+919850123456","LN20260001","2026-01-15",2,"COMPLETED","$now"
"BEN-4913","Suresh Tukaram Pawar","+919822334455","LN20260002","2026-02-01",1,"RESUBMISSION_REQUIRED","$now"
''';
    }
  }

  String generatePdfPreviewText(SystemReportType type) {
    return '''
===================================================================
GOVERNMENT OF MAHARASHTRA • LAON UTILIZATION OFFICIAL REPORT
===================================================================
Report Title: ${type.title}
Generated On: ${DateTime.now().toString()}
Classification: CONFIDENTIAL & OFFICIAL USE ONLY

Summary:
${type.description}

Data Records preview ready. System digital signature attached.
===================================================================
''';
  }
}
