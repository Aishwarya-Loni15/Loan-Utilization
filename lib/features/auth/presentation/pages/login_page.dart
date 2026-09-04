import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_form.dart';

import '../../../../data/datasources/remote/firebase_database_seeder.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;
  bool _isSeeding = false;

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).login(email, password);
      // Auto seed database collections after successful login
      FirebaseDatabaseSeeder().seedAllCollections().catchError((_) {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seedDatabaseNow() async {
    setState(() => _isSeeding = true);
    try {
      await FirebaseDatabaseSeeder().seedAllCollections();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 All 13 Collections Created & Populated in Firebase Firestore!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seeding Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const AuthHeader(
                title: 'Sign In',
                subtitle: 'Enter your credentials to access the monitoring portal',
              ),
              const SizedBox(height: 32),
              LoginForm(
                onSubmit: _handleLogin,
                isLoading: _isLoading,
                onForgotPassword: (email) {
                  final uri = email.isNotEmpty
                      ? '/forgot-password?email=${Uri.encodeComponent(email)}'
                      : '/forgot-password';
                  context.push(uri);
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Register Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Demo Credentials Selector
              const Text(
                '⚡ Quick Demo One-Tap Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.account_balance_rounded, size: 16, color: AppColors.primary),
                    label: const Text('Bank Manager Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    onPressed: () => _handleLogin('manager.sbi@bank.co.in', 'manager123'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.shield_rounded, size: 16, color: AppColors.secondary),
                    label: const Text('State Officer Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.08),
                    onPressed: () => _handleLogin('officer.solapur@loanlens.gov.in', 'officer123'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.purple),
                    label: const Text('Admin Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.purple.withValues(alpha: 0.08),
                    onPressed: () => _handleLogin('admin@loanlens.gov.in', 'admin123'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.agriculture_rounded, size: 16, color: AppColors.success),
                    label: const Text('Beneficiary Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.success.withValues(alpha: 0.08),
                    onPressed: () => _handleLogin('ramesh.farmer@gmail.com', 'farmer123'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSeeding ? null : _seedDatabaseNow,
                  icon: _isSeeding
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_rounded, color: AppColors.primary),
                  label: Text(_isSeeding ? 'Creating 13 Collections in Firebase...' : 'Seed All 13 Firebase Collections Now'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

