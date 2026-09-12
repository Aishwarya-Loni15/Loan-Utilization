import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).login(email, password);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const AuthHeader(
                title: 'Portal Sign In',
                subtitle: 'Loan Utilization Tracking & Monitoring System',
              ),
              const SizedBox(height: 28),
              AppCard(
                elevation: 2,
                padding: const EdgeInsets.all(22.0),
                child: LoginForm(
                  onSubmit: _handleLogin,
                  isLoading: _isLoading,
                  onForgotPassword: (email) {
                    final uri = email.isNotEmpty
                        ? '/forgot-password?email=${Uri.encodeComponent(email)}'
                        : '/forgot-password';
                    context.push(uri);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text(
                      'Register Here',
                      style: TextStyle(
                        color: AppColors.primaryViolet,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  const Text(
                    'Encrypted & Secure Government Portal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



