import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums/risk_level.dart';
import '../../../../core/enums/submission_status.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../beneficiary/presentation/widgets/recent_submission_card.dart';
import '../../../loans/providers/loan_provider.dart';
import '../../../utilization/providers/utilization_provider.dart';

class BankSubmissionsPage extends ConsumerStatefulWidget {
  final String initialFilter; // 'all', 'pending', 'approved', 'rejected', 'highRisk'

  const BankSubmissionsPage({
    super.key,
    this.initialFilter = 'all',
  });

  @override
  ConsumerState<BankSubmissionsPage> createState() => _BankSubmissionsPageState();
}

class _BankSubmissionsPageState extends ConsumerState<BankSubmissionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = ['all', 'pending', 'approved', 'rejected', 'resubmission', 'highRisk'];

  @override
  void initState() {
    super.initState();
    int initialIdx = _filters.indexOf(widget.initialFilter);
    if (initialIdx == -1) initialIdx = 0;
    _tabController = TabController(length: _filters.length, vsync: this, initialIndex: initialIdx);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bankLoansAsync = ref.watch(bankLoansProvider);
    final allSubmissionsAsync = ref.watch(allSubmissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Submissions & Audits'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Submissions'),
            Tab(text: 'Pending Verification'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Resubmission Required'),
            Tab(text: 'Suspicious ⚠️'),
          ],
        ),
      ),
      body: bankLoansAsync.when(
        data: (bankLoans) {
          final bankLoanIds = bankLoans.map((l) => l.loanId).toSet();

          return allSubmissionsAsync.when(
            data: (allSubmissions) {
              final targetSubmissions = allSubmissions.where((s) => bankLoanIds.contains(s.loanId)).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(context, targetSubmissions),
                  _buildList(
                    context,
                    targetSubmissions.where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.underOfficerReview || s.status == SubmissionStatus.aiProcessing).toList(),
                    emptyTitle: 'No Pending Verification',
                    emptyDesc: 'All utilization submissions for this branch have been audited.',
                  ),
                  _buildList(
                    context,
                    targetSubmissions.where((s) => s.status == SubmissionStatus.approved || s.status == SubmissionStatus.aiVerified).toList(),
                    emptyTitle: 'No Approved Submissions',
                    emptyDesc: 'There are no approved utilization submissions yet.',
                  ),
                  _buildList(
                    context,
                    targetSubmissions.where((s) => s.status == SubmissionStatus.rejected).toList(),
                    emptyTitle: 'No Rejected Submissions',
                    emptyDesc: 'There are no rejected submissions.',
                  ),
                  _buildList(
                    context,
                    targetSubmissions.where((s) => s.status == SubmissionStatus.resubmissionRequired).toList(),
                    emptyTitle: 'No Resubmission Requests',
                    emptyDesc: 'No submissions currently require beneficiary resubmission.',
                  ),
                  _buildList(
                    context,
                    targetSubmissions.where((s) => s.riskLevel == RiskLevel.high).toList(),
                    emptyTitle: 'No Suspicious Submissions',
                    emptyDesc: 'No suspicious evidence discrepancies detected for this branch.',
                  ),
                ],
              );
            },
            loading: () => const LoadingWidget(message: 'Loading submissions...'),
            error: (e, _) => AppErrorWidget(message: e.toString()),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading branch loans...'),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<dynamic> submissions, {
    String emptyTitle = 'No Submissions',
    String emptyDesc = 'No submissions found matching this audit criteria.',
  }) {
    if (submissions.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        description: emptyDesc,
        icon: Icons.assignment_turned_in_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return RecentSubmissionCard(
          submission: submission,
          onTap: () {
            context.push('/bank-verification/${submission.submissionId}');
          },
        );
      },
    );
  }
}
