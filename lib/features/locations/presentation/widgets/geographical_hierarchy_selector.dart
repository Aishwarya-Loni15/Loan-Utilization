import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/constants/app_locations.dart';

class GeographicalHierarchySelector extends ConsumerStatefulWidget {
  final String? initialState;
  final String? initialDistrict;
  final String? initialTaluka;
  final String? initialVillage;
  final Function(String state, String district, String taluka, String village) onChanged;

  const GeographicalHierarchySelector({
    super.key,
    this.initialState,
    this.initialDistrict,
    this.initialTaluka,
    this.initialVillage,
    required this.onChanged,
  });

  @override
  ConsumerState<GeographicalHierarchySelector> createState() => _GeographicalHierarchySelectorState();
}

class _GeographicalHierarchySelectorState extends ConsumerState<GeographicalHierarchySelector> {
  late String _selectedState;
  late String _selectedDistrict;
  late String _selectedTaluka;
  late String _selectedVillage;

  List<String> get _states => AppLocations.states;
  Map<String, List<String>> get _districtsMap => AppLocations.districtsMap;
  Map<String, List<String>> get _talukasMap => AppLocations.talukasMap;
  Map<String, List<String>> get _villagesMap => AppLocations.villagesMap;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.initialState ?? 'Maharashtra';
    _selectedDistrict = widget.initialDistrict ?? 'Solapur';
    _selectedTaluka = widget.initialTaluka ?? 'Pandharpur';
    _selectedVillage = widget.initialVillage ?? 'Pandharpur';
  }

  void _notifyChange() {
    widget.onChanged(_selectedState, _selectedDistrict, _selectedTaluka, _selectedVillage);
  }

  @override
  Widget build(BuildContext context) {
    final availableDistricts = _districtsMap[_selectedState] ?? ['Solapur'];
    if (!availableDistricts.contains(_selectedDistrict)) {
      _selectedDistrict = availableDistricts.first;
    }

    final availableTalukas = _talukasMap[_selectedDistrict] ?? ['Pandharpur'];
    if (!availableTalukas.contains(_selectedTaluka)) {
      _selectedTaluka = availableTalukas.first;
    }

    final availableVillages = _villagesMap[_selectedTaluka] ?? ['Pandharpur'];
    if (!availableVillages.contains(_selectedVillage)) {
      _selectedVillage = availableVillages.first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Geographical Hierarchy Selection',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'State → District → Taluka → Village',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const Divider(height: 20),

          // State Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            decoration: const InputDecoration(
              labelText: '1. State',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedState = val);
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: 12),

          // District Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedDistrict,
            decoration: const InputDecoration(
              labelText: '2. District',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: availableDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedDistrict = val);
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: 12),

          // Taluka Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedTaluka,
            decoration: const InputDecoration(
              labelText: '3. Taluka',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: availableTalukas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedTaluka = val);
                _notifyChange();
              }
            },
          ),
          const SizedBox(height: 12),

          // Village Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedVillage,
            decoration: const InputDecoration(
              labelText: '4. Village',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: availableVillages.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedVillage = val);
                _notifyChange();
              }
            },
          ),
        ],
      ),
    );
  }
}
