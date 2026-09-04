enum UserRole {
  admin,
  stateOfficer,
  bankManager,
  beneficiary;

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.stateOfficer:
        return 'STATE_OFFICER';
      case UserRole.bankManager:
        return 'BANK_MANAGER';
      case UserRole.beneficiary:
        return 'BENEFICIARY';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'System Administrator';
      case UserRole.stateOfficer:
        return 'State Officer';
      case UserRole.bankManager:
        return 'Bank Manager';
      case UserRole.beneficiary:
        return 'Beneficiary';
    }
  }

  static UserRole fromString(String? role) {
    final cleanRole = role?.toUpperCase().replaceAll(' ', '_');
    switch (cleanRole) {
      case 'ADMIN':
      case 'SYSTEM_ADMINISTRATOR':
        return UserRole.admin;
      case 'STATE_OFFICER':
      case 'OFFICER':
      case 'STATEOFFICER':
      case 'STATE_OFFICER_ROLE':
        return UserRole.stateOfficer;
      case 'BANK_MANAGER':
      case 'MANAGER':
      case 'BANKMANAGER':
      case 'BANK_MANAGER_ROLE':
      case 'MANAGER_ROLE':
        return UserRole.bankManager;
      case 'BENEFICIARY':
      default:
        return UserRole.beneficiary;
    }
  }
}

