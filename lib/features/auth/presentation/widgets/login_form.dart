import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../app/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onSubmit;
  final void Function(String email)? onForgotPassword;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onSubmit,
    this.onForgotPassword,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'officer@maharashtra.gov.in',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            validator: Validators.validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (widget.onForgotPassword != null) {
                  widget.onForgotPassword!(_emailController.text.trim());
                }
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primaryViolet,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Sign In to Portal',
            isLoading: widget.isLoading,
            onPressed: _submit,
            icon: Icons.login_rounded,
          ),
        ],
      ),
    );
  }
}

