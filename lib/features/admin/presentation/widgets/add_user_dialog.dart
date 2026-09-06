import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../data/datasources/remote/user_remote_datasource.dart';
import '../../../../data/models/user_model.dart';
import '../../../bank/providers/bank_provider.dart';
import '../../providers/admin_provider.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  const AddUserDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: AddUserDialog(),
      ),
    );
  }

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _districtController = TextEditingController(text: 'Solapur');
  final _talukaController = TextEditingController(text: 'Pandharpur');
  final _villageController = TextEditingController(text: 'Pandharpur');

  UserRole _selectedRole = UserRole.stateOfficer;
  String? _selectedBankId;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Location Dropdown States
  String _selectedState = 'Maharashtra';
  String _selectedDistrict = 'Solapur';
  String _selectedTaluka = 'Pandharpur';
  String _selectedVillage = 'Pandharpur';

  bool _isCustomState = false;
  bool _isCustomDistrict = false;
  bool _isCustomTaluka = false;
  bool _isCustomVillage = false;

  List<String> get _states => AppLocations.states;
  Map<String, List<String>> get _districtsMap => AppLocations.districtsMap;
  Map<String, List<String>> get _talukasMap => AppLocations.talukasMap;
  Map<String, List<String>> get _villagesMap => AppLocations.villagesMap;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    if (!_isCustomState) _stateController.text = _selectedState;
    if (!_isCustomDistrict) _districtController.text = _selectedDistrict;
    if (!_isCustomTaluka) _talukaController.text = _selectedTaluka;
    if (!_isCustomVillage) _villageController.text = _selectedVillage;
  }

  void _onStateChanged(String val) {
    setState(() {
      _selectedState = val;
      _isCustomState = val == 'Other State';
      if (_isCustomState) {
        _stateController.clear();
      } else {
        _stateController.text = val;
      }

      final availableDistricts = _districtsMap[val] ?? ['Other District'];
      _selectedDistrict = availableDistricts.first;
      _isCustomDistrict = _selectedDistrict == 'Other District';
      if (!_isCustomDistrict) _districtController.text = _selectedDistrict;

      final availableTalukas = _talukasMap[_selectedDistrict] ?? ['Other Taluka'];
      _selectedTaluka = availableTalukas.first;
      _isCustomTaluka = _selectedTaluka == 'Other Taluka';
      if (!_isCustomTaluka) _talukaController.text = _selectedTaluka;

      final availableVillages = _villagesMap[_selectedTaluka] ?? ['Other Village'];
      _selectedVillage = availableVillages.first;
      _isCustomVillage = _selectedVillage == 'Other Village';
      if (!_isCustomVillage) _villageController.text = _selectedVillage;
    });
  }

  void _onDistrictChanged(String val) {
    setState(() {
      _selectedDistrict = val;
      _isCustomDistrict = val == 'Other District';
      if (_isCustomDistrict) {
        _districtController.clear();
      } else {
        _districtController.text = val;
      }

      final availableTalukas = _talukasMap[val] ?? ['Other Taluka'];
      _selectedTaluka = availableTalukas.first;
      _isCustomTaluka = _selectedTaluka == 'Other Taluka';
      if (!_isCustomTaluka) _talukaController.text = _selectedTaluka;

      final availableVillages = _villagesMap[_selectedTaluka] ?? ['Other Village'];
      _selectedVillage = availableVillages.first;
      _isCustomVillage = _selectedVillage == 'Other Village';
      if (!_isCustomVillage) _villageController.text = _selectedVillage;
    });
  }

  void _onTalukaChanged(String val) {
    setState(() {
      _selectedTaluka = val;
      _isCustomTaluka = val == 'Other Taluka';
      if (_isCustomTaluka) {
        _talukaController.clear();
      } else {
        _talukaController.text = val;
      }

      final availableVillages = _villagesMap[val] ?? ['Other Village'];
      _selectedVillage = availableVillages.first;
      _isCustomVillage = _selectedVillage == 'Other Village';
      if (!_isCustomVillage) _villageController.text = _selectedVillage;
    });
  }

  void _onVillageChanged(String val) {
    setState(() {
      _selectedVillage = val;
      _isCustomVillage = val == 'Other Village';
      if (_isCustomVillage) {
        _villageController.clear();
      } else {
        _villageController.text = val;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final stateName = _isCustomState ? _stateController.text.trim() : _selectedState;
      final district = _isCustomDistrict ? _districtController.text.trim() : _selectedDistrict;
      final taluka = _isCustomTaluka ? _talukaController.text.trim() : _selectedTaluka;
      final village = _isCustomVillage ? _villageController.text.trim() : _selectedVillage;

      String uid;
      try {
        FirebaseApp secondaryApp;
        try {
          secondaryApp = Firebase.app('SecondaryAdminUserApp');
        } catch (_) {
          secondaryApp = await Firebase.initializeApp(
            name: 'SecondaryAdminUserApp',
            options: Firebase.app().options,
          );
        }
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        final cred = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = cred.user!.uid;
        await secondaryAuth.signOut();
      } catch (_) {
        // Fallback UID if secondary auth cannot initialize or is offline
        uid = 'usr_${_selectedRole.name}_${DateTime.now().millisecondsSinceEpoch}';
      }

      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        address: address,
        state: stateName,
        district: district,
        taluka: taluka,
        village: village,
        role: _selectedRole,
        bankId: _selectedRole == UserRole.bankManager ? _selectedBankId : null,
      );

      // Save user password to registered passwords cache
      final storage = LocalStorageService();
      final passwords = storage.getJson('registered_passwords') ?? {};
      passwords[email.trim().toLowerCase()] = password;
      await storage.setJson('registered_passwords', passwords);

      // Save user to database
      await UserRemoteDataSource().createUser(newUser);

      // If assigning a bank manager to a bank, update bank repository
      if (_selectedRole == UserRole.bankManager && _selectedBankId != null) {
        await ref.read(bankRepositoryProvider).assignBankManager(
              _selectedBankId!,
              uid,
              name,
            );
      }

      ref.invalidate(allUsersProvider);
      ref.invalidate(banksProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedRole.displayName} created and saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create user: ${e.toString()}'),
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
    final banksAsync = ref.watch(banksProvider);

    final availableDistricts = _districtsMap[_selectedState] ?? ['Other District'];
    final currentDistrict = availableDistricts.contains(_selectedDistrict) ? _selectedDistrict : availableDistricts.first;

    final availableTalukas = _talukasMap[currentDistrict] ?? ['Other Taluka'];
    final currentTaluka = availableTalukas.contains(_selectedTaluka) ? _selectedTaluka : availableTalukas.first;

    final availableVillages = _villagesMap[currentTaluka] ?? ['Other Village'];
    final currentVillage = availableVillages.contains(_selectedVillage) ? _selectedVillage : availableVillages.first;

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
                        const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Add New System User',
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

              // Role Selector
              const Text(
                'Assign Role',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RoleChip(
                    label: 'State Officer',
                    icon: Icons.shield_outlined,
                    isSelected: _selectedRole == UserRole.stateOfficer,
                    onTap: () => setState(() => _selectedRole = UserRole.stateOfficer),
                  ),
                  const SizedBox(width: 8),
                  _RoleChip(
                    label: 'Bank Manager',
                    icon: Icons.account_balance_outlined,
                    isSelected: _selectedRole == UserRole.bankManager,
                    onTap: () => setState(() => _selectedRole = UserRole.bankManager),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'e.g. Suresh Deshmukh',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.validateName(v, 'Full Name'),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'officer@laonlens.gov.in',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                validator: Validators.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) => Validators.validateMobile(v, 'Phone Number'),
              ),
              const SizedBox(height: 16),

              // Bank selector if Bank Manager role
              if (_selectedRole == UserRole.bankManager) ...[
                const Text(
                  'Assign Partner Bank',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                banksAsync.when(
                  data: (banks) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedBankId,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Select Bank Branch'),
                      items: banks
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text('${b.name} (${b.branchName})'),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedBankId = val),
                      validator: (val) => val == null ? 'Please select a bank branch' : null,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading banks: $e'),
                ),
                const SizedBox(height: 16),
              ],

              AppTextField(
                controller: _addressController,
                label: 'Official Address',
                hint: 'District Collectorate / Branch Office',
                prefixIcon: Icons.home_outlined,
                validator: (v) => Validators.validateRequired(v, 'Address'),
              ),
              const SizedBox(height: 16),

              // State and District Dropdowns Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'State',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedState,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.map_outlined),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _states
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _onStateChanged(val);
                          },
                        ),
                        if (_isCustomState) ...[
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _stateController,
                            label: 'Specify State',
                            hint: 'Enter state name',
                            validator: (v) => Validators.validateRequired(v, 'State'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'District',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: currentDistrict,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.location_city_outlined),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: availableDistricts
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _onDistrictChanged(val);
                          },
                        ),
                        if (_isCustomDistrict) ...[
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _districtController,
                            label: 'Specify District',
                            hint: 'Enter district name',
                            validator: (v) => Validators.validateRequired(v, 'District'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Taluka and Village Dropdowns Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taluka',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: currentTaluka,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.holiday_village_outlined),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: availableTalukas
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _onTalukaChanged(val);
                          },
                        ),
                        if (_isCustomTaluka) ...[
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _talukaController,
                            label: 'Specify Taluka',
                            hint: 'Enter taluka name',
                            validator: (v) => Validators.validateRequired(v, 'Taluka'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Village / HQ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: currentVillage,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.home_work_outlined),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: availableVillages
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _onVillageChanged(val);
                          },
                        ),
                        if (_isCustomVillage) ...[
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _villageController,
                            label: 'Specify Village',
                            hint: 'Enter village name',
                            validator: (v) => Validators.validateRequired(v, 'Village'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Save User to Database',
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

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey[100],
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
