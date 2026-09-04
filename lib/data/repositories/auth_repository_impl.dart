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



  @override
  Future<UserEntity> login({required String email, required String password}) async {
    try {
      final storage = LocalStorageService();
      final cleanEmail = email.trim().toLowerCase();
      final cleanDigits = cleanEmail.replaceAll(RegExp(r'\D'), '');

      if (cleanEmail.isEmpty) {
        throw const AuthFailure(message: 'Please enter your registered email address.');
      }
      if (password.trim().isEmpty) {
        throw const AuthFailure(message: 'Please enter your password.');
      }

      // 1. Explicit Password Check for Demo Accounts
      if (cleanEmail == 'admin@loanlens.gov.in') {
        if (password != 'admin123') {
          throw const AuthFailure(message: 'Invalid password. Please enter your valid registered password.');
        }
        final admin = UserModel(
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
        await storage.setBool('is_admin_logged_in', true);
        await storage.setString('logged_in_user_uid', admin.uid);
        return admin;
      }

      if (cleanEmail == 'manager.sbi@bank.co.in' || cleanEmail == 'manager') {
        if (password != 'manager123') {
          throw const AuthFailure(message: 'Invalid password. Please enter your valid registered password.');
        }
        final manager = MockDatabaseService().users.where((u) => u.role == UserRole.bankManager).firstOrNull ??
            const UserModel(
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
        await storage.setBool('is_user_logged_in', true);
        await storage.setString('logged_in_user_uid', manager.uid);
        return manager;
      }

      if (cleanEmail == 'officer.solapur@loanlens.gov.in' || cleanEmail == 'officer') {
        if (password != 'officer123') {
          throw const AuthFailure(message: 'Invalid password. Please enter your valid registered password.');
        }
        final officer = MockDatabaseService().users.where((u) => u.role == UserRole.stateOfficer).firstOrNull ??
            const UserModel(
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
        await storage.setBool('is_user_logged_in', true);
        await storage.setString('logged_in_user_uid', officer.uid);
        return officer;
      }

      if (cleanEmail == 'ramesh.farmer@gmail.com' || cleanEmail == 'farmer') {
        if (password != 'farmer123') {
          throw const AuthFailure(message: 'Invalid password. Please enter your valid registered password.');
        }
        final beneficiary = MockDatabaseService().users.where((u) => u.role == UserRole.beneficiary).firstOrNull ??
            const UserModel(
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
        await storage.setBool('is_user_logged_in', true);
        await storage.setString('logged_in_user_uid', beneficiary.uid);
        return beneficiary;
      }

      // 2. Attempt Firebase Auth Login (if input contains '@')
      if (cleanEmail.contains('@')) {
        try {
          final credential = await _authRemoteDataSource.login(
            email: cleanEmail,
            password: password,
          );
          final uid = credential.user!.uid;
          final user = await _userRemoteDataSource.getUser(uid);
          if (user != null) {
            await storage.setBool('is_user_logged_in', true);
            await storage.setString('logged_in_user_uid', user.uid);
            return user;
          }

          final fallbackRole = (cleanEmail.contains('admin'))
              ? UserRole.admin
              : (cleanEmail.contains('officer'))
                  ? UserRole.stateOfficer
                  : (cleanEmail.contains('manager') || cleanEmail.contains('bank'))
                      ? UserRole.bankManager
                      : UserRole.beneficiary;

          final fallbackUser = UserModel(
            uid: uid,
            email: credential.user?.email ?? cleanEmail,
            name: credential.user?.displayName ?? cleanEmail.split('@').first,
            phone: credential.user?.phoneNumber ?? '',
            role: fallbackRole,
            bankId: fallbackRole == UserRole.bankManager ? 'bnk_sbi_sol' : null,
            state: 'Maharashtra',
            district: 'Solapur',
            taluka: 'Pandharpur',
            village: 'Kavathe',
            address: 'Registered User Account',
          );
          await _userRemoteDataSource.createUser(fallbackUser);
          await storage.setBool('is_user_logged_in', true);
          await storage.setString('logged_in_user_uid', fallbackUser.uid);
          return fallbackUser;
        } catch (e) {
          // If Firebase Auth returned invalid credentials or wrong password, stop and throw clear error
          final failure = FirebaseExceptionHandler.handleException(e);
          if (failure is AuthFailure &&
              (failure.message.contains('Invalid') ||
                  failure.message.contains('password') ||
                  failure.message.contains('credential'))) {
            throw failure;
          }
        }
      }

      // 3. Fallback lookup in Firestore database & Mock database
      var mockMatch = MockDatabaseService().users.where((u) {
        final uEmail = u.email.toLowerCase().trim();
        final uName = u.name.toLowerCase().trim();
        final uUid = u.uid.toLowerCase().trim();
        final uPhone = u.phone.replaceAll(RegExp(r'\D'), '');
        return uEmail == cleanEmail ||
            uName == cleanEmail ||
            uUid == cleanEmail ||
            (cleanDigits.isNotEmpty && uPhone.endsWith(cleanDigits));
      }).firstOrNull;

      if (mockMatch == null) {
        try {
          final allUsers = await _userRemoteDataSource.getAllUsers();
          mockMatch = allUsers.where((u) {
            final uEmail = u.email.toLowerCase();
            final uPhone = u.phone.replaceAll(RegExp(r'\D'), '');
            return uEmail == cleanEmail || (cleanDigits.isNotEmpty && uPhone.endsWith(cleanDigits));
          }).firstOrNull;
        } catch (_) {}
      }

      if (mockMatch != null) {
        // Basic password check for registered database accounts
        if (password.length < 4) {
          throw const AuthFailure(message: 'Invalid password. Please enter your valid registered password.');
        }

        final finalUser = (mockMatch.role == UserRole.bankManager && (mockMatch.bankId == null || mockMatch.bankId!.isEmpty))
            ? UserModel(
                uid: mockMatch.uid,
                name: mockMatch.name,
                email: mockMatch.email,
                phone: mockMatch.phone,
                address: mockMatch.address,
                state: mockMatch.state,
                district: mockMatch.district,
                taluka: mockMatch.taluka,
                village: mockMatch.village,
                role: mockMatch.role,
                bankId: 'bnk_sbi_sol',
                branchId: mockMatch.branchId,
                createdAt: mockMatch.createdAt,
                updatedAt: mockMatch.updatedAt,
                isActive: mockMatch.isActive,
              )
            : mockMatch;

        await storage.setBool('is_user_logged_in', true);
        await storage.setString('logged_in_user_uid', finalUser.uid);
        return finalUser;
      }

      throw AuthFailure(message: 'No registered account found for "$email". Please check email or register.');
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
      String uid;
      try {
        final credential = await _authRemoteDataSource.register(
          email: email,
          password: password,
        );
        uid = credential.user!.uid;
      } catch (_) {
        uid = 'usr_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
      }

      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
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
