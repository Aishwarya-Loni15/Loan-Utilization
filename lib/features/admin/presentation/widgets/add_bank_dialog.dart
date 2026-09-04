import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/bank_model.dart';
import '../../../bank/providers/bank_provider.dart';
import '../../providers/admin_provider.dart';

class AddBankDialog extends ConsumerStatefulWidget {
  const AddBankDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: AddBankDialog(),
      ),
    );
  }

  @override
  ConsumerState<AddBankDialog> createState() => _AddBankDialogState();
}

class _AddBankDialogState extends ConsumerState<AddBankDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _branchController = TextEditingController();
  final _ifscController = TextEditingController();
  final _districtController = TextEditingController(text: 'Solapur');
  final _stateController = TextEditingController(text: 'Maharashtra');

  String? _selectedManagerId;
  String? _selectedManagerName;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _branchController.dispose();
    _ifscController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final branch = _branchController.text.trim();
      final ifsc = _ifscController.text.trim().toUpperCase();
      final district = _districtController.text.trim();
      final stateName = _stateController.text.trim();

      final bankId = 'bnk_${ifsc.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch % 10000}';

      final newBank = BankModel(
        id: bankId,
        name: name,
        branchName: branch,
        ifscCode: ifsc,
        district: district,
        state: stateName,
        managerId: _selectedManagerId,
        managerName: _selectedManagerName,
        totalLoansDisbursed: 0,
        totalAmountDisbursed: 0.0,
      );

      final bankRepository = ref.read(bankRepositoryProvider);
      await bankRepository.createBank(newBank);

      ref.invalidate(banksProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bank "$name ($branch)" added to database successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add bank: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, color: AppColors.success, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Add Partner Bank Branch',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _nameController,
                label: 'Bank Name',
                hint: 'e.g. State Bank of India',
                prefixIcon: Icons.account_balance_outlined,
                validator: (v) => Validators.validateRequired(v, 'Bank Name'),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _branchController,
                label: 'Branch Name',
                hint: 'e.g. Pandharpur Main',
                prefixIcon: Icons.location_city_outlined,
                validator: (v) => Validators.validateRequired(v, 'Branch Name'),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _ifscController,
                label: 'IFSC Code',
                hint: 'e.g. SBIN0000445',
                prefixIcon: Icons.code_rounded,
                validator: (v) => Validators.validateRequired(v, 'IFSC Code'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _districtController,
                      label: 'District',
                      validator: (v) => Validators.validateRequired(v, 'District'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      validator: (v) => Validators.validateRequired(v, 'State'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Assign Bank Manager (Optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              usersAsync.when(
                data: (users) {
                  final managers = users.where((u) => u.role == UserRole.bankManager).toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedManagerId,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('Select Manager (Optional)'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      ...managers.map((m) => DropdownMenuItem(
                            value: m.uid,
                            child: Text('${m.name} (${m.email})'),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedManagerId = val;
                        if (val != null) {
                          _selectedManagerName = managers.firstWhere((m) => m.uid == val).name;
                        } else {
                          _selectedManagerName = null;
                        }
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading users: $e'),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Save Bank to Database',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
