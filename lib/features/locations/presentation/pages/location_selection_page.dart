import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../domain/entities/state.dart';
import '../../../../domain/entities/district.dart';
import '../../../../domain/entities/taluka.dart';
import '../../../../domain/entities/village.dart';
import '../../providers/location_provider.dart';
import '../widgets/location_dropdown.dart';

class LocationSelectionPage extends ConsumerStatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  ConsumerState<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends ConsumerState<LocationSelectionPage> {
  StateEntity? _selectedState;
  DistrictEntity? _selectedDistrict;
  TalukaEntity? _selectedTaluka;
  VillageEntity? _selectedVillage;

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(statesProvider);
    final districtsAsync = _selectedState != null
        ? ref.watch(districtsProvider(_selectedState!.id))
        : const AsyncValue.data(<DistrictEntity>[]);
    final talukasAsync = _selectedDistrict != null
        ? ref.watch(talukasProvider(_selectedDistrict!.id))
        : const AsyncValue.data(<TalukaEntity>[]);
    final villagesAsync = _selectedTaluka != null
        ? ref.watch(villagesProvider(_selectedTaluka!.id))
        : const AsyncValue.data(<VillageEntity>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location Hierarchy'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hierarchical Location Filtering',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select state, district, taluka, and village sequentially from Firestore data.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              // State Dropdown
              statesAsync.when(
                data: (states) => LocationDropdown<StateEntity>(
                  label: 'State',
                  value: _selectedState,
                  items: states,
                  itemLabelBuilder: (s) => s.name,
                  onChanged: (val) {
                    setState(() {
                      _selectedState = val;
                      _selectedDistrict = null;
                      _selectedTaluka = null;
                      _selectedVillage = null;
                    });
                  },
                ),
                loading: () => const LocationDropdown<StateEntity>(
                  label: 'State',
                  value: null,
                  items: [],
                  itemLabelBuilder: _emptyName,
                  onChanged: _nullOnChanged,
                  isLoading: true,
                ),
                error: (e, _) => Text('Error loading states: $e'),
              ),
              const SizedBox(height: 16),
              // District Dropdown
              districtsAsync.when(
                data: (districts) => LocationDropdown<DistrictEntity>(
                  label: 'District',
                  value: _selectedDistrict,
                  items: districts,
                  itemLabelBuilder: (d) => d.name,
                  onChanged: (val) {
                    setState(() {
                      _selectedDistrict = val;
                      _selectedTaluka = null;
                      _selectedVillage = null;
                    });
                  },
                ),
                loading: () => const LocationDropdown<DistrictEntity>(
                  label: 'District',
                  value: null,
                  items: [],
                  itemLabelBuilder: _emptyName,
                  onChanged: _nullOnChanged,
                  isLoading: true,
                ),
                error: (e, _) => Text('Error loading districts: $e'),
              ),
              const SizedBox(height: 16),
              // Taluka Dropdown
              talukasAsync.when(
                data: (talukas) => LocationDropdown<TalukaEntity>(
                  label: 'Taluka',
                  value: _selectedTaluka,
                  items: talukas,
                  itemLabelBuilder: (t) => t.name,
                  onChanged: (val) {
                    setState(() {
                      _selectedTaluka = val;
                      _selectedVillage = null;
                    });
                  },
                ),
                loading: () => const LocationDropdown<TalukaEntity>(
                  label: 'Taluka',
                  value: null,
                  items: [],
                  itemLabelBuilder: _emptyName,
                  onChanged: _nullOnChanged,
                  isLoading: true,
                ),
                error: (e, _) => Text('Error loading talukas: $e'),
              ),
              const SizedBox(height: 16),
              // Village Dropdown
              villagesAsync.when(
                data: (villages) => LocationDropdown<VillageEntity>(
                  label: 'Village',
                  value: _selectedVillage,
                  items: villages,
                  itemLabelBuilder: (v) => v.name,
                  onChanged: (val) {
                    setState(() {
                      _selectedVillage = val;
                    });
                  },
                ),
                loading: () => const LocationDropdown<VillageEntity>(
                  label: 'Village',
                  value: null,
                  items: [],
                  itemLabelBuilder: _emptyName,
                  onChanged: _nullOnChanged,
                  isLoading: true,
                ),
                error: (e, _) => Text('Error loading villages: $e'),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Confirm Selection',
                onPressed: _selectedVillage != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selected: ${_selectedState?.name} -> ${_selectedDistrict?.name} -> ${_selectedTaluka?.name} -> ${_selectedVillage?.name}',
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _emptyName(dynamic item) => '';
void _nullOnChanged(dynamic item) {}
