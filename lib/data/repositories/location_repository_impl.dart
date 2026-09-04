import '../../core/errors/firebase_exception_handler.dart';
import '../../domain/entities/state.dart';
import '../../domain/entities/district.dart';
import '../../domain/entities/taluka.dart';
import '../../domain/entities/village.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/remote/state_remote_datasource.dart';
import '../datasources/remote/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final StateRemoteDataSource _stateRemoteDataSource;
  final LocationRemoteDataSource _locationRemoteDataSource;

  LocationRepositoryImpl({
    StateRemoteDataSource? stateRemoteDataSource,
    LocationRemoteDataSource? locationRemoteDataSource,
  })  : _stateRemoteDataSource = stateRemoteDataSource ?? StateRemoteDataSource(),
        _locationRemoteDataSource = locationRemoteDataSource ?? LocationRemoteDataSource();

  @override
  Future<List<StateEntity>> getStates() async {
    try {
      return await _stateRemoteDataSource.getStates();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<DistrictEntity>> getDistricts(String stateId) async {
    try {
      return await _locationRemoteDataSource.getDistricts(stateId);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<TalukaEntity>> getTalukas(String districtId) async {
    try {
      return await _locationRemoteDataSource.getTalukas(districtId);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<VillageEntity>> getVillages(String talukaId) async {
    try {
      return await _locationRemoteDataSource.getVillages(talukaId);
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }
}
