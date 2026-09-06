import 'dart:async';
import '../../core/enums/user_role.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/firebase_exception_handler.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_database_service.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../models/user_model.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/utils/validators.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final UserRemoteDataSource _userRemoteDataSource;

  AuthRepositoryImpl({
    AuthRemoteDataSource? authRemoteDataSource,
    UserRemoteDataSource? userRemoteDataSource,
  })  : _authRemoteDataSource = authRemoteDataSource ?? AuthRemoteDataSource(),
        _userRemoteDataSource = userRemoteDataSource ?? UserRemoteDataSource();

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authRemoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      return await getCurrentUser();
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final storage = LocalStorageService();

      final isAdmin = storage.getBool('is_admin_logged_in') ?? false;
      final isLoggedIn = storage.getBool('is_user_logged_in') ?? false;

      // Default: Return null so the Login Page is shown on app launch
      if (!isAdmin && !isLoggedIn) {
        return null;
      }

      if (isAdmin) {
        return UserModel(
          uid: 'user_admin_01',
          email: 'admin@loanlens.gov.in',
          name: 'Rajesh Sharma (Admin)',
          phone: '+919876543210',
          role: UserRole.admin,
          state: 'st_mah',
          district: 'dst_sol',
          taluka: 'tlk_pan',
          village: 'vlg_kav',
          address: 'HQ, Mumbai',
        );
      }

      final savedUid = storage.getString('logged_in_user_uid');
      if (savedUid != null && savedUid.isNotEmpty) {
        final mockUser = MockDatabaseService().users.where((u) => u.uid == savedUid).firstOrNull;
        if (mockUser != null) return mockUser;
        final remoteUser = await _userRemoteDataSource.getUser(savedUid);
        if (remoteUser != null) return remoteUser;
      }

      final firebaseUser = _authRemoteDataSource.currentUser;
      if (firebaseUser == null) return null;
      return await _userRemoteDataSource.getUser(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }



  Map<String, String> _getRegisteredPasswords() {
    final storage = LocalStorageService();
    final jsonMap = storage.getJson('registered_passwords') ?? {};
    final Map<String, String> passwords = {};
    jsonMap.forEach((k, v) => passwords[k.toString().toLowerCase().trim()] = v.toString());

    // Default registered demo account passwords
    passwords.putIfAbsent('admin@loanlens.gov.in', () => 'admin123');
    passwords.putIfAbsent('manager.sbi@bank.co.in', () => 'manager123');
    passwords.putIfAbsent('officer.solapur@loanlens.gov.in', () => 'officer123');
    passwords.putIfAbsent('ramesh.farmer@gmail.com', () => 'farmer123');

    return passwords;
  }

  Future<void> _saveRegisteredPassword(String email, String password) async {
    final storage = LocalStorageService();
    final passwords = _getRegisteredPasswords();
    passwords[email.trim().toLowerCase()] = password;
    await storage.setJson('registered_passwords', passwords);
  }

  Future<UserModel?> _getUserByEmailOrRole(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check MockDatabaseService
    var user = MockDatabaseService().users.where((u) => u.email.trim().toLowerCase() == cleanEmail).firstOrNull;

    // Check Firestore
    user ??= await _userRemoteDataSource.getUserByEmail(cleanEmail);

    // Fallbacks for standard roles if not found in DB
    if (user == null) {
      if (cleanEmail == 'admin@loanlens.gov.in') {
        user = const UserModel(
          uid: 'user_admin_01',
          email: 'admin@loanlens.gov.in',
          name: 'Rajesh Sharma (Admin)',
          phone: '+919876543210',
          role: UserRole.admin,
          state: 'st_mah',
          district: 'dst_sol',
          taluka: 'tlk_pan',
          village: 'vlg_kav',
          address: 'HQ, Mumbai',
        );
      } else if (cleanEmail == 'manager.sbi@bank.co.in') {
        user = const UserModel(
          uid: 'user_bank_sbi',
          email: 'manager.sbi@bank.co.in',
          name: 'Amitabh Deshmukh',
          phone: '+919422003311',
          role: UserRole.bankManager,
          state: 'st_mah',
          district: 'dst_sol',
          taluka: 'tlk_pan',
          village: 'vlg_kav',
          address: 'SBI Branch, Pandharpur',
          bankId: 'bnk_sbi_sol',
        );
      } else if (cleanEmail == 'officer.solapur@loanlens.gov.in') {
        user = const UserModel(
          uid: 'user_officer_sol',
          email: 'officer.solapur@loanlens.gov.in',
          name: 'Priya Kulkarni',
          phone: '+919822110044',
          role: UserRole.stateOfficer,
          state: 'st_mah',
          district: 'dst_sol',
          taluka: 'tlk_pan',
          village: 'vlg_kav',
          address: 'District Collectorate, Solapur',
        );
      } else if (cleanEmail == 'ramesh.farmer@gmail.com') {
        user = const UserModel(
          uid: 'user_ben_01',
          email: 'ramesh.farmer@gmail.com',
          name: 'Ramesh Vitthal Patil',
          phone: '+919850123456',
          role: UserRole.beneficiary,
          state: 'st_mah',
          district: 'dst_sol',
          taluka: 'tlk_pan',
          village: 'vlg_kav',
          address: 'Gat No. 142, Kavathe Village, Pandharpur',
        );
      }
    }

    if (user != null && user.role == UserRole.bankManager && (user.bankId == null || user.bankId!.isEmpty)) {
      user = UserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        phone: user.phone,
        address: user.address,
        state: user.state,
        district: user.district,
        taluka: user.taluka,
        village: user.village,
        role: user.role,
        bankId: 'bnk_sbi_sol',
        branchId: user.branchId,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        isActive: user.isActive,
      );
    }

    return user;
  }

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    try {
      final storage = LocalStorageService();
      final cleanEmail = email.trim().toLowerCase();

      if (cleanEmail.isEmpty) {
        throw const AuthFailure(message: 'Please enter your registered email address.');
      }
      if (password.trim().isEmpty) {
        throw const AuthFailure(message: 'Please enter your password.');
      }

      final registeredPasswords = _getRegisteredPasswords();

      // Short-name demo account aliases check (e.g. "manager", "officer", "farmer")
      String effectiveEmail = cleanEmail;
      if (cleanEmail == 'admin') effectiveEmail = 'admin@loanlens.gov.in';
      if (cleanEmail == 'manager') effectiveEmail = 'manager.sbi@bank.co.in';
      if (cleanEmail == 'officer') effectiveEmail = 'officer.solapur@loanlens.gov.in';
      if (cleanEmail == 'farmer') effectiveEmail = 'ramesh.farmer@gmail.com';

      // 1. Check if email is in registered passwords map
      if (registeredPasswords.containsKey(effectiveEmail)) {
        if (registeredPasswords[effectiveEmail] != password) {
          throw const AuthFailure(message: 'Invalid email or password.');
        }

        final user = await _getUserByEmailOrRole(effectiveEmail);
        if (user != null) {
          if (user.role == UserRole.admin) {
            await storage.setBool('is_admin_logged_in', true);
          } else {
            await storage.setBool('is_user_logged_in', true);
          }
          await storage.setString('logged_in_user_uid', user.uid);
          return user;
        }
      }

      // 2. Attempt Firebase Auth Login if input contains '@'
      if (effectiveEmail.contains('@')) {
        try {
          final credential = await _authRemoteDataSource.login(
            email: effectiveEmail,
            password: password,
          );
          final uid = credential.user!.uid;
          await _saveRegisteredPassword(effectiveEmail, password);

          final user = await _userRemoteDataSource.getUser(uid);
          if (user != null) {
            if (user.role == UserRole.admin) {
              await storage.setBool('is_admin_logged_in', true);
            } else {
              await storage.setBool('is_user_logged_in', true);
            }
            await storage.setString('logged_in_user_uid', user.uid);
            return user;
          }
        } catch (e) {
          final failure = FirebaseExceptionHandler.handleException(e);
          if (failure is AuthFailure) {
            throw const AuthFailure(message: 'Invalid email or password.');
          }
        }
      }

      // 3. Fallback check for users registered in database without local password cache entry
      final dbUser = await _getUserByEmailOrRole(effectiveEmail);
      if (dbUser != null) {
        // Since user is in DB, check if password was set or matches
        throw const AuthFailure(message: 'Invalid email or password.');
      }

      throw const AuthFailure(message: 'Invalid email or password.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String state,
    required String district,
    required String taluka,
    required String village,
    required UserRole role,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final registeredPasswords = _getRegisteredPasswords();

      // Check if email is already registered
      if (registeredPasswords.containsKey(cleanEmail)) {
        throw const AuthFailure(message: 'This email is already registered. Please log in.');
      }

      final existingUser = MockDatabaseService().users.where((u) => u.email.trim().toLowerCase() == cleanEmail).firstOrNull ??
          await _userRemoteDataSource.getUserByEmail(cleanEmail);
      if (existingUser != null) {
        throw const AuthFailure(message: 'This email is already registered. Please log in.');
      }

      // Save credential locally so user can log in with registered password
      await _saveRegisteredPassword(cleanEmail, password);

      String uid;
      try {
        final credential = await _authRemoteDataSource.register(
          email: cleanEmail,
          password: password,
        );
        uid = credential.user!.uid;
      } catch (_) {
        uid = 'usr_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
      }

      final userModel = UserModel(
        uid: uid,
        name: name,
        email: cleanEmail,
        phone: phone,
        address: address,
        state: state,
        district: district,
        taluka: taluka,
        village: village,
        role: role,
      );

      await _userRemoteDataSource.createUser(userModel);
      return userModel;
    } catch (e) {
      if (e is Failure) rethrow;
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final storage = LocalStorageService();
      await storage.remove('is_admin_logged_in');
      await storage.remove('is_user_logged_in');
      await storage.remove('logged_in_user_uid');
      await _authRemoteDataSource.logout();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw const AuthFailure(message: 'Please enter a valid email address.');
    }

    final isDemoAccount = cleanEmail == 'admin@loanlens.gov.in' ||
        cleanEmail == 'manager.sbi@bank.co.in' ||
        cleanEmail == 'officer.solapur@loanlens.gov.in' ||
        cleanEmail == 'ramesh.farmer@gmail.com';

    if (isDemoAccount) {
      // Demo accounts are pre-configured test users
      return;
    }

    try {
      // 1. Attempt sending password reset email directly via Firebase Auth
      await _authRemoteDataSource.resetPassword(cleanEmail);
    } catch (e) {
      // 2. If Firebase Auth returned user-not-found (e.g. registered in Firestore/app without Firebase Auth entry),
      // auto-create the Firebase Auth user entry and send the real reset link email
      try {
        final tempPassword = 'AuthReset#${DateTime.now().millisecondsSinceEpoch}!';
        await _authRemoteDataSource.register(email: cleanEmail, password: tempPassword);
        await _authRemoteDataSource.resetPassword(cleanEmail);
        return;
      } catch (_) {
        final mockMatch = MockDatabaseService().users.where((u) => u.email.toLowerCase().trim() == cleanEmail).firstOrNull;
        final firestoreUser = await _userRemoteDataSource.getUserByEmail(cleanEmail);

        if (mockMatch != null || firestoreUser != null || Validators.validateEmail(cleanEmail) == null) {
          return;
        }
        throw FirebaseExceptionHandler.handleException(e);
      }
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _authRemoteDataSource.sendEmailVerification();
    } catch (e) {
      throw FirebaseExceptionHandler.handleException(e);
    }
  }
}
