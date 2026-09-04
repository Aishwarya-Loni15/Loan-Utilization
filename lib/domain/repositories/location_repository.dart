import '../../domain/entities/state.dart';
import '../../domain/entities/district.dart';
import '../../domain/entities/taluka.dart';
import '../../domain/entities/village.dart';

abstract class LocationRepository {
  Future<List<StateEntity>> getStates();
  Future<List<DistrictEntity>> getDistricts(String stateId);
  Future<List<TalukaEntity>> getTalukas(String districtId);
  Future<List<VillageEntity>> getVillages(String talukaId);
}
