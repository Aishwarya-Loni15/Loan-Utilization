import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/utils/currency_utils.dart';

class JurisdictionDrilldownPage extends StatefulWidget {
  const JurisdictionDrilldownPage({super.key});

  @override
  State<JurisdictionDrilldownPage> createState() => _JurisdictionDrilldownPageState();
}

class _JurisdictionDrilldownPageState extends State<JurisdictionDrilldownPage> {
  // Breadcrumb Drill-Down Levels:
  // 0: State -> 1: District -> 2: Taluka -> 3: Village -> 4: Loan -> 5: Beneficiary
  int _currentLevel = 0;
  final String _selectedState = 'Maharashtra';
  String? _selectedDistrict;
  String? _selectedTaluka;
  String? _selectedVillage;
  String? _selectedLoanId;

  final Map<String, List<String>> _districts = {
    'Maharashtra': ['Solapur', 'Pune', 'Nashik', 'Satara'],
  };

  final Map<String, List<String>> _talukas = {
    'Solapur': ['Pandharpur', 'Malshiras', 'Sangole', 'Barshi'],
  };

  final Map<String, List<String>> _villages = {
    'Pandharpur': ['Kavathe', 'Bhalwani', 'Tebhurni', 'Wakhari'],
  };

  final Map<String, List<Map<String, String>>> _loans = {
    'Kavathe': [
      {'loanId': 'LN20260001', 'accountNo': 'LN20260001', 'purpose': 'Solar Agriculture Pump', 'amount': '185000', 'beneficiary': 'Ramesh Vitthal Patil', 'mobile': '+919850123456', 'status': 'Approved'},
      {'loanId': 'LN20260002', 'accountNo': 'LN20260002', 'purpose': 'Drip Irrigation Setup', 'amount': '120000', 'beneficiary': 'Suresh Tukaram Pawar', 'mobile': '+919822334455', 'status': 'Pending Verification'},
    ],
  };

  void _drillToDistrict(String dist) {
    setState(() {
      _selectedDistrict = dist;
      _currentLevel = 1;
    });
  }

  void _drillToTaluka(String taluka) {
    setState(() {
      _selectedTaluka = taluka;
      _currentLevel = 2;
    });
  }

  void _drillToVillage(String village) {
    setState(() {
      _selectedVillage = village;
      _currentLevel = 3;
    });
  }

  void _drillToLoan(String loanId) {
    setState(() {
      _selectedLoanId = loanId;
      _currentLevel = 4;
    });
  }

  void _drillToBeneficiary() {
    setState(() {
      _currentLevel = 5;
    });
  }

  void _resetToLevel(int level) {
    setState(() {
      _currentLevel = level;
      if (level < 1) _selectedDistrict = null;
      if (level < 2) _selectedTaluka = null;
      if (level < 3) _selectedVillage = null;
      if (level < 4) _selectedLoanId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Geographical Drill-Down'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBreadcrumbChip('State: $_selectedState', 0),
                    if (_selectedDistrict != null) ...[
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      _buildBreadcrumbChip('District: $_selectedDistrict', 1),
                    ],
                    if (_selectedTaluka != null) ...[
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      _buildBreadcrumbChip('Taluka: $_selectedTaluka', 2),
                    ],
                    if (_selectedVillage != null) ...[
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      _buildBreadcrumbChip('Village: $_selectedVillage', 3),
                    ],
                    if (_selectedLoanId != null) ...[
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      _buildBreadcrumbChip('Loan: $_selectedLoanId', 4),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                      _buildBreadcrumbChip('Beneficiary', 5),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Drill-Down Body
            Expanded(
              child: _buildCurrentLevelView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbChip(String label, int level) {
    final isActive = _currentLevel == level;
    return GestureDetector(
      onTap: () => _resetToLevel(level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLevelView() {
    switch (_currentLevel) {
      case 0:
        // State Level -> Choose District
        final dists = _districts[_selectedState] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level 1: Select District in $_selectedState', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: dists.length,
                itemBuilder: (ctx, i) {
                  final dist = dists[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                      title: Text(dist, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Disbursed Amount: ₹2.45 Cr • Active Loans: 142'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => _drillToDistrict(dist),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case 1:
        // District Level -> Choose Taluka
        final tals = _talukas[_selectedDistrict] ?? ['Pandharpur', 'Malshiras', 'Sangole', 'Barshi'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level 2: Select Taluka in $_selectedDistrict District', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: tals.length,
                itemBuilder: (ctx, i) {
                  final tal = tals[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_city_outlined, color: AppColors.primary),
                      title: Text(tal, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Disbursed: ₹68.5 Lakhs • Submissions: 38'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => _drillToTaluka(tal),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case 2:
        // Taluka Level -> Choose Village
        final vils = _villages[_selectedTaluka] ?? ['Kavathe', 'Bhalwani', 'Tebhurni', 'Wakhari'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level 3: Select Village in $_selectedTaluka Taluka', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: vils.length,
                itemBuilder: (ctx, i) {
                  final vil = vils[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.holiday_village_outlined, color: AppColors.primary),
                      title: Text(vil, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Beneficiaries: 12 • Active Loans: 14'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => _drillToVillage(vil),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case 3:
        // Village Level -> Choose Loan
        final loansList = _loans[_selectedVillage] ?? [
          {'loanId': 'LN20260001', 'accountNo': 'LN20260001', 'purpose': 'Solar Agriculture Pump', 'amount': '185000', 'beneficiary': 'Ramesh Vitthal Patil', 'mobile': '+919850123456', 'status': 'Approved'},
          {'loanId': 'LN20260002', 'accountNo': 'LN20260002', 'purpose': 'Drip Irrigation Setup', 'amount': '120000', 'beneficiary': 'Suresh Tukaram Pawar', 'mobile': '+919822334455', 'status': 'Pending Verification'},
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level 4: Select Loan Record in $_selectedVillage Village', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: loansList.length,
                itemBuilder: (ctx, i) {
                  final l = loansList[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined, color: AppColors.primary),
                      title: Text('Loan Account: ${l['accountNo']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Purpose: ${l['purpose']} • Beneficiary: ${l['beneficiary']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(CurrencyUtils.formatINR(double.parse(l['amount']!)), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                      onTap: () => _drillToLoan(l['loanId']!),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case 4:
        // Loan Level -> Show Loan & Option to view Beneficiary
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level 5: Loan Details Record (${_selectedLoanId ?? "LN20260001"})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              const Text('Scheme Name: PM-KUSUM Solar Tractor Scheme', style: TextStyle(fontSize: 13)),
              const Text('Sanctioned Outlay: ₹1,85,000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const Text('Bank & Branch: State Bank of India (Solapur Main)', style: TextStyle(fontSize: 13)),
              const Text('Sanction Date: 15 Jan 2026', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _drillToBeneficiary,
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('DRILL DOWN TO BENEFICIARY PROFILE'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        );

      case 5:
      default:
        // Beneficiary Level -> Complete Profile
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success, size: 28),
                  SizedBox(width: 10),
                  Text('Level 6: Beneficiary Final Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Beneficiary Name: Ramesh Vitthal Patil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Text('Mobile Number: +919850123456', style: TextStyle(fontSize: 13)),
              const Text('Aadhaar / ID Hash: XXXX-XXXX-4912', style: TextStyle(fontSize: 13)),
              const Text('Assigned Hierarchy: Maharashtra → Solapur → Pandharpur → Kavathe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _resetToLevel(0),
                child: const Text('RESET TO STATE LEVEL'),
              ),
            ],
          ),
        );
    }
  }
}
