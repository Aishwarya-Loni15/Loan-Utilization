import 'package:flutter/material.dart';
import '../../../../core/constants/app_locations.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  final Future<void> Function({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String state,
    required String district,
    required String taluka,
    required String village,
    required UserRole role,
  }) onSubmit;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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

  final UserRole _selectedRole = UserRole.beneficiary;
  bool _obscurePassword = true;

  // Dropdown States
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final finalState = _isCustomState ? _stateController.text.trim() : _selectedState;
      final finalDistrict = _isCustomDistrict ? _districtController.text.trim() : _selectedDistrict;
      final finalTaluka = _isCustomTaluka ? _talukaController.text.trim() : _selectedTaluka;
      final finalVillage = _isCustomVillage ? _villageController.text.trim() : _selectedVillage;

      widget.onSubmit(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        state: finalState,
        district: finalDistrict,
        taluka: finalTaluka,
        village: finalVillage,
        role: _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableDistricts = _districtsMap[_selectedState] ?? ['Other District'];
    final currentDistrict = availableDistricts.contains(_selectedDistrict) ? _selectedDistrict : availableDistricts.first;

    final availableTalukas = _talukasMap[currentDistrict] ?? ['Other Taluka'];
    final currentTaluka = availableTalukas.contains(_selectedTaluka) ? _selectedTaluka : availableTalukas.first;

    final availableVillages = _villagesMap[currentTaluka] ?? ['Other Village'];
    final currentVillage = availableVillages.contains(_selectedVillage) ? _selectedVillage : availableVillages.first;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'John Doe',
            prefixIcon: Icons.person_outline,
            validator: (v) => Validators.validateName(v, 'Full Name'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'name@example.com',
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
          AppTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'House No, Street',
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
                      'Village',
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
            text: 'Create Account',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

