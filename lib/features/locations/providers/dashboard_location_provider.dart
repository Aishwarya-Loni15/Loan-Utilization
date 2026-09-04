import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_locations.dart';

class DashboardLocationState {
  final String district;
  final String taluka;
  final String village;

  const DashboardLocationState({
    this.district = 'Solapur',
    this.taluka = 'Pandharpur',
    this.village = 'Ojewadi',
  });

  DashboardLocationState copyWith({
    String? district,
    String? taluka,
    String? village,
  }) {
    return DashboardLocationState(
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      village: village ?? this.village,
    );
  }
}

class DashboardLocationNotifier extends StateNotifier<DashboardLocationState> {
  DashboardLocationNotifier() : super(const DashboardLocationState());

  static List<String> get districts {
    final list = <String>['All Districts'];
    for (final distList in AppLocations.districtsMap.values) {
      for (final dist in distList) {
        if (!list.contains(dist) && dist != 'Other District') {
          list.add(dist);
        }
      }
    }
    list.add('Other District');
    return list;
  }

  List<String> getAvailableTalukas(String district) {
    if (district == 'All Districts') return ['All Talukas'];
    final rawTalukas = AppLocations.getTalukas(district);
    return ['All Talukas', ...rawTalukas.where((t) => t != 'Other Taluka'), 'Other Taluka'];
  }

  List<String> getAvailableVillages(String taluka) {
    if (taluka == 'All Talukas') return ['All Villages'];
    final rawVillages = AppLocations.getVillages(taluka);
    return ['All Villages', ...rawVillages.where((v) => v != 'Other Village'), 'Other Village'];
  }

  void setDistrict(String newDistrict) {
    final availableTalukas = getAvailableTalukas(newDistrict);
    final newTaluka = availableTalukas.contains(state.taluka) ? state.taluka : availableTalukas.first;
    final availableVillages = getAvailableVillages(newTaluka);
    final newVillage = availableVillages.contains(state.village) ? state.village : availableVillages.first;

    state = state.copyWith(
      district: newDistrict,
      taluka: newTaluka,
      village: newVillage,
    );
  }

  void setTaluka(String newTaluka) {
    final availableVillages = getAvailableVillages(newTaluka);
    final newVillage = availableVillages.contains(state.village) ? state.village : availableVillages.first;

    state = state.copyWith(
      taluka: newTaluka,
      village: newVillage,
    );
  }

  void setVillage(String newVillage) {
    state = state.copyWith(village: newVillage);
  }
}

final dashboardLocationFilterProvider = StateNotifierProvider<DashboardLocationNotifier, DashboardLocationState>((ref) {
  return DashboardLocationNotifier();
});
