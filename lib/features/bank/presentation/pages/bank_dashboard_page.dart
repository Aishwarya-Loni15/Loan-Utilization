import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/utils/validators.dart';
import 'package:laon/core/widgets/app_text_field.dart';
import 'package:laon/core/widgets/error_widget.dart';
import 'package:laon/core/widgets/loading_widget.dart';
import 'package:laon/data/datasources/remote/user_remote_datasource.dart';
import 'package:laon/data/models/user_model.dart';
import 'package:laon/data/repositories/loan_repository_impl.dart';
import 'package:laon/domain/entities/loan.dart';
import 'package:laon/features/auth/providers/auth_provider.dart';
import 'package:laon/features/bank/providers/bank_provider.dart';
import 'package:laon/features/loans/providers/loan_provider.dart';
import 'package:laon/features/locations/presentation/widgets/dashboard_location_filter_widget.dart';
import 'package:laon/features/utilization/providers/utilization_provider.dart';
import '../widgets/bank_loan_card.dart';
import '../widgets/bank_statistics.dart';
import '../widgets/geotagged_submission_card.dart';
import '../widgets/link_offline_loan_dialog.dart';

class BankDashboardPage extends ConsumerWidget {
  const BankDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: LoadingWidget(message: 'Initializing Bank Manager Console...'),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: AppErrorWidget(message: e.toString()),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bank Manager Console')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text(
                    'No active session found',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text('Please sign in with bank manager credentials.', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Return to Sign In'),
                  ),
                ],
              ),
            ),
          );
        }

        final metricsAsync = ref.watch(bankDashboardMetricsProvider);
        final bankLoansAsync = ref.watch(bankLoansProvider);
        final allSubmissionsAsync = ref.watch(allSubmissionsProvider);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'Bank Manager Console' : user.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Branch ID: ${(user.bankId != null && user.bankId!.isNotEmpty) ? user.bankId : "bnk_sbi_sol"} • Manager',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_active_outlined),
                tooltip: 'Manager Notifications',
                onPressed: () => context.push('/role-notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                tooltip: 'Branch Reports',
                onPressed: () => context.push('/bank-reports'),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await ref.read(currentUserProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardLocationFilterWidget(),
                  _buildBranchHeroCard(context, user),
                  const SizedBox(height: 16),
                  metricsAsync.when(
                    data: (metrics) => Column(
                      children: [
                        BankStatisticsWidget(metrics: metrics),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => LinkOfflineLoanDialog.show(context),
                                icon: const Icon(Icons.add_link_rounded),
                                label: const Text('Register Existing Loan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push('/bank-submissions?filter=pending'),
                                icon: const Icon(Icons.rate_review_outlined),
                                label: Text('Pending Queue (${metrics.pendingReviews})'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const LoadingWidget(message: 'Calculating bank metrics...'),
                    error: (e, _) => AppErrorWidget(message: e.toString()),
                  ),
                  const SizedBox(height: 24),

                  // Dedicated Manager Connect & Beneficiary Email Verification Card
                  const _ManagerEmailConnectWidget(),
                  const SizedBox(height: 24),

                  // Geotagged Beneficiary Submissions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.photo_camera_front_rounded, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Geotagged Beneficiary Submissions',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/bank-submissions'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  allSubmissionsAsync.when(
                    data: (submissions) {
                      final bankLoanIds = bankLoansAsync.valueOrNull?.map((l) => l.loanId).toSet() ?? {};
                      final managerSubmissions = submissions.where((s) => bankLoanIds.contains(s.loanId)).toList();

                      if (managerSubmissions.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'No geotagged submissions uploaded yet for your linked beneficiaries.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      final recentGeotagged = managerSubmissions.take(3).toList();
                      return Column(
                        children: recentGeotagged.map((sub) {
                          return GeotaggedSubmissionCard(
                            submission: sub,
                            onTap: () => context.push('/bank-verification/${sub.submissionId}'),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LoadingWidget(message: 'Loading geotagged evidence...'),
                    error: (e, _) => AppErrorWidget(message: e.toString()),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Branch Actions & Controls',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.45,
                    children: [
                      _BankActionCard(
                        title: 'Register Existing Loan',
                        subtitle: 'Create Loan & Beneficiary Entry',
                        icon: Icons.note_add_outlined,
                        color: AppColors.success,
                        onTap: () => LinkOfflineLoanDialog.show(context),
                      ),
                      _BankActionCard(
                        title: 'Branch Submissions',
                        subtitle: 'Audit Utilization Proofs & AI',
                        icon: Icons.fact_check_outlined,
                        color: AppColors.primary,
                        onTap: () => context.push('/bank-submissions'),
                      ),
                      _BankActionCard(
                        title: 'Branch Loans Portfolio',
                        subtitle: 'View Linked Loans List',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.secondary,
                        onTap: () => context.push('/bank-loans'),
                      ),
                      _BankActionCard(
                        title: 'Branch Analytics',
                        subtitle: 'Disbursement Audit Reports',
                        icon: Icons.bar_chart_rounded,
                        color: Colors.indigo,
                        onTap: () => context.push('/bank-reports'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Branch Loans Portfolio',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/bank-loans'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  bankLoansAsync.when(
                    data: (loans) {
                      if (loans.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('No active loan records associated with this bank branch.'),
                        );
                      }

                      final displayLoans = loans.take(5).toList();
                      return Column(
                        children: displayLoans.map((loan) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: BankLoanCardWidget(
                              loan: loan,
                              onTap: () {
                                context.push('/loan-details/${loan.loanId}', extra: loan);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LoadingWidget(message: 'Loading bank loans portfolio...'),
                    error: (e, _) => AppErrorWidget(message: e.toString()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchHeroCard(BuildContext context, dynamic user) {
    final branchName = (user.address != null && user.address.isNotEmpty)
        ? user.address
        : 'SBI Branch, Pandharpur Main';
    final managerName = (user.name != null && user.name.isNotEmpty) ? user.name : 'Amitabh Deshmukh';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            Colors.indigo.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'State Bank of India',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        branchName,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'BRANCH MANAGER',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Branch Manager Console', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(managerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Branch IFSC Code', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                  const SizedBox(height: 2),
                  const Text('SBIN0000445', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManagerEmailConnectWidget extends ConsumerStatefulWidget {
  const _ManagerEmailConnectWidget();

  @override
  ConsumerState<_ManagerEmailConnectWidget> createState() => _ManagerEmailConnectWidgetState();
}

class _ManagerEmailConnectWidgetState extends ConsumerState<_ManagerEmailConnectWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ramesh.farmer@gmail.com');

  bool _isSearching = false;
  UserModel? _verifiedUser;
  List<LoanEntity> _userLoans = [];
  String? _lookupError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchAndVerify() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        setState(() {
          _verifiedUser = null;
          _userLoans = [];
          _lookupError = 'Enter a beneficiary email address.';
        });
      }
      return;
    }

    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _lookupError = null;
    });

    try {
      final user = await UserRemoteDataSource().getUserByEmail(email);
      if (!mounted) return;

      if (user != null) {
        final allLoans = await LoanRepositoryImpl().getLoans();
        if (!mounted) return;

        final matchingLoans = allLoans.where((l) =>
            (l.beneficiaryEmail ?? '').trim().toLowerCase() == user.email.trim().toLowerCase() ||
            l.beneficiaryId == user.uid
        ).toList();

        if (mounted) {
          setState(() {
            _verifiedUser = user;
            _userLoans = matchingLoans;
            _lookupError = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _verifiedUser = null;
            _userLoans = [];
            _lookupError = 'No registered beneficiary found for "$email".';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifiedUser = null;
          _userLoans = [];
          _lookupError = 'Lookup error: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.mark_email_read_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect Loan by Beneficiary Email',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Verify beneficiary mobile, village & connected loan details',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _emailController,
                    label: 'Beneficiary Registered Email',
                    hint: 'e.g. ramesh.farmer@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: Validators.validateEmail,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching ? null : _searchAndVerify,
                    icon: _isSearching
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.verified_rounded, size: 16),
                    label: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            if (_verifiedUser != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: const [
                              Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Beneficiary Verified & Matched',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _verifiedUser!.role.displayName,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    _InfoRow(label: 'Full Name:', value: _verifiedUser!.name, isBold: true),
                    const SizedBox(height: 4),
                    _InfoRow(label: 'Mobile Number:', value: _verifiedUser!.phone),
                    const SizedBox(height: 4),
                    _InfoRow(
                      label: 'Village:',
                      value: _verifiedUser!.village.isEmpty ? 'Kavathe (Pandharpur)' : _verifiedUser!.village,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      label: 'Taluka / District:',
                      value: '${_verifiedUser!.taluka.isEmpty ? "Pandharpur" : _verifiedUser!.taluka}, ${_verifiedUser!.district.isEmpty ? "Solapur" : _verifiedUser!.district}',
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      label: 'State:',
                      value: _verifiedUser!.state.isEmpty ? 'Maharashtra' : _verifiedUser!.state,
                    ),
                    if (_verifiedUser!.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _InfoRow(label: 'Address:', value: _verifiedUser!.address),
                    ],
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Connected Loans (${_userLoans.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                        ),
                        if (_userLoans.isNotEmpty)
                          Text(
                            'Total Sanctioned: ₹${_userLoans.fold(0.0, (sum, l) => sum + l.sanctionedAmount).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_userLoans.isEmpty)
                      const Text(
                        'No existing loans currently linked to this email. Click below to connect a loan.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      )
                    else
                      Column(
                        children: _userLoans.map((l) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${l.loanAccountNumber ?? l.loanId} (${l.schemeName})',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${l.disbursedAmount.toStringAsFixed(0)} • ${l.status.name.toUpperCase()}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          LinkOfflineLoanDialog.show(context, initialEmail: _verifiedUser!.email);
                        },
                        icon: const Icon(Icons.add_link_rounded, size: 18),
                        label: Text('Connect & Register Loan for ${_verifiedUser!.name}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_lookupError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lookupError!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BankActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BankActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

