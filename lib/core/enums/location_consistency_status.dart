enum LocationConsistencyStatus {
  locationConsistent('Location Consistent', 'GPS location is within expected land/village boundary'),
  locationPossiblyInconsistent('Location Possibly Inconsistent', 'GPS location is outside primary target boundary'),
  locationUnavailable('Location Unavailable', 'GPS location data could not be acquired');

  final String label;
  final String description;

  const LocationConsistencyStatus(this.label, this.description);

  static LocationConsistencyStatus fromString(String? val) {
    if (val == null) return LocationConsistencyStatus.locationUnavailable;
    final clean = val.trim().toLowerCase();
    if (clean.contains('consistent') && !clean.contains('inconsistent')) {
      return LocationConsistencyStatus.locationConsistent;
    }
    if (clean.contains('inconsistent')) {
      return LocationConsistencyStatus.locationPossiblyInconsistent;
    }
    return LocationConsistencyStatus.locationUnavailable;
  }
}
