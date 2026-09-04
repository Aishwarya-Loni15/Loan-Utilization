import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/features/locations/presentation/widgets/geographical_hierarchy_badge.dart';
import 'package:laon/features/locations/providers/location_provider.dart';

class ManageLocationsPage extends ConsumerWidget {
  const ManageLocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statesAsync = ref.watch(statesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geographical Loan Hierarchy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        '4-Tier Geographical Hierarchy',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'State → District → Taluka → Village',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Every loan scheme and beneficiary profile in Laon Utilization is mapped to this administrative boundary chain.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Administrative Boundaries Explorer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            statesAsync.when(
              data: (states) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: states.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final state = states[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      elevation: 0,
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.map_rounded, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          'State: ${state.name} (${state.code})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: const Text('Top-level State Boundary', style: TextStyle(fontSize: 11)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(),
                          ),
                          _DistrictTileTree(stateId: state.id),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(message: 'Loading geographical hierarchy...'),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistrictTileTree extends ConsumerWidget {
  final String stateId;

  const _DistrictTileTree({required this.stateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtsAsync = ref.watch(districtsProvider(stateId));

    return districtsAsync.when(
      data: (districts) {
        if (districts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No districts mapped.'),
          );
        }

        return Column(
          children: districts.map((district) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Card(
                color: Colors.blue.shade50.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                elevation: 0,
                child: ExpansionTile(
                  leading: Icon(Icons.location_city_rounded, color: Colors.blue.shade700),
                  title: Text(
                    'District: ${district.name}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade900),
                  ),
                  subtitle: const Text('District Boundary Level', style: TextStyle(fontSize: 10)),
                  children: [
                    _TalukaTileTree(districtId: district.id, districtName: district.name),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _TalukaTileTree extends ConsumerWidget {
  final String districtId;
  final String districtName;

  const _TalukaTileTree({required this.districtId, required this.districtName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talukasAsync = ref.watch(talukasProvider(districtId));

    return talukasAsync.when(
      data: (talukas) {
        if (talukas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No talukas mapped.'),
          );
        }

        return Column(
          children: talukas.map((taluka) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Card(
                color: Colors.teal.shade50.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.teal.shade200),
                ),
                elevation: 0,
                child: ExpansionTile(
                  leading: Icon(Icons.holiday_village_outlined, color: Colors.teal.shade700),
                  title: Text(
                    'Taluka: ${taluka.name}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal.shade900),
                  ),
                  subtitle: const Text('Sub-District / Taluka Level', style: TextStyle(fontSize: 10)),
                  children: [
                    _VillageList(talukaId: taluka.id, talukaName: taluka.name, districtName: districtName),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _VillageList extends ConsumerWidget {
  final String talukaId;
  final String talukaName;
  final String districtName;

  const _VillageList({
    required this.talukaId,
    required this.talukaName,
    required this.districtName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villagesAsync = ref.watch(villagesProvider(talukaId));

    return villagesAsync.when(
      data: (villages) {
        if (villages.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('No villages mapped.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: villages.map((village) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: GeographicalHierarchyBadge(
                  state: 'Maharashtra',
                  district: districtName,
                  taluka: talukaName,
                  village: village.name,
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
