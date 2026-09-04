import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/features/locations/providers/dashboard_location_provider.dart';

class DashboardLocationFilterWidget extends ConsumerWidget {
  const DashboardLocationFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(dashboardLocationFilterProvider);
    final locationNotifier = ref.read(dashboardLocationFilterProvider.notifier);

    final availableDistricts = DashboardLocationNotifier.districts;
    final availableTalukas = locationNotifier.getAvailableTalukas(locationState.district);
    final availableVillages = locationNotifier.getAvailableVillages(locationState.taluka);

    final selectedDistrict = availableDistricts.contains(locationState.district)
        ? locationState.district
        : availableDistricts.first;
    final selectedTaluka = availableTalukas.contains(locationState.taluka)
        ? locationState.taluka
        : availableTalukas.first;
    final selectedVillage = availableVillages.contains(locationState.village)
        ? locationState.village
        : availableVillages.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Geographical Location Filter',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.filter_alt_rounded, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Live Filter',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildDistrictDropdown(selectedDistrict, availableDistricts, locationNotifier)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTalukaDropdown(selectedTaluka, availableTalukas, locationNotifier)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildVillageDropdown(selectedVillage, availableVillages, locationNotifier)),
                  ],
                );
              }

              return Column(
                children: [
                  _buildDistrictDropdown(selectedDistrict, availableDistricts, locationNotifier),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTalukaDropdown(selectedTaluka, availableTalukas, locationNotifier)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildVillageDropdown(selectedVillage, availableVillages, locationNotifier)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.explore_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '📍 Active Location: $selectedDistrict → $selectedTaluka → $selectedVillage',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictDropdown(
    String selected,
    List<String> items,
    DashboardLocationNotifier notifier,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('dist_$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'District',
        prefixIcon: const Icon(Icons.location_city_rounded, size: 18, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: (val) {
        if (val != null) {
          notifier.setDistrict(val);
        }
      },
    );
  }

  Widget _buildTalukaDropdown(
    String selected,
    List<String> items,
    DashboardLocationNotifier notifier,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('tal_$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Taluka',
        prefixIcon: const Icon(Icons.landscape_rounded, size: 18, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: (val) {
        if (val != null) {
          notifier.setTaluka(val);
        }
      },
    );
  }

  Widget _buildVillageDropdown(
    String selected,
    List<String> items,
    DashboardLocationNotifier notifier,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('vil_$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Village',
        prefixIcon: const Icon(Icons.holiday_village_rounded, size: 18, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: (val) {
        if (val != null) {
          notifier.setVillage(val);
        }
      },
    );
  }
}
