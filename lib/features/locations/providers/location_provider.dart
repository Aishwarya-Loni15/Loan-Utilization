import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/location_repository_impl.dart';
import '../../../domain/entities/state.dart';
import '../../../domain/entities/district.dart';
import '../../../domain/entities/taluka.dart';
import '../../../domain/entities/village.dart';
import '../../../domain/repositories/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

final statesProvider = FutureProvider<List<StateEntity>>((ref) async {
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.getStates();
});

final districtsProvider = FutureProvider.family<List<DistrictEntity>, String>((ref, stateId) async {
  if (stateId.isEmpty) return [];
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.getDistricts(stateId);
});

final talukasProvider = FutureProvider.family<List<TalukaEntity>, String>((ref, districtId) async {
  if (districtId.isEmpty) return [];
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.getTalukas(districtId);
});

final villagesProvider = FutureProvider.family<List<VillageEntity>, String>((ref, talukaId) async {
  if (talukaId.isEmpty) return [];
  final repository = ref.watch(locationRepositoryProvider);
  return await repository.getVillages(talukaId);
});
