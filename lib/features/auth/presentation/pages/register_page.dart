import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/register_form.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _isLoading = false;

  Future<void> _handleRegister({
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
    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            address: address,
            stateName: state,
            district: district,
            taluka: taluka,
            village: village,
            role: role,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! Please log in with your credentials.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('New Registration'),
        backgroundColor: AppColors.darkViolet,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const AuthHeader(
                title: 'User Registration',
                subtitle: 'Enter your details and jurisdiction location to register your profile',
              ),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(20.0),
                elevation: 2,
                child: RegisterForm(
                  onSubmit: _handleRegister,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

