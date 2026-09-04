import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class AuditLogsPage extends StatelessWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockAuditLogs = [
      {
        'id': 'audit_1001',
        'officer': 'Suresh Kumar (State Officer)',
        'action': 'APPROVED',
        'submissionId': 'sub_8832',
        'time': '10 mins ago',
        'notes': 'Geotag locked and invoice matched.',
      },
      {
        'id': 'audit_1002',
        'officer': 'Anil Deshmukh (Bank Manager)',
        'action': 'REJECTED',
        'submissionId': 'sub_4109',
        'time': '45 mins ago',
        'notes': 'Discrepancy in invoice amount vs sanctioned limit.',
      },
      {
        'id': 'audit_1003',
        'officer': 'Admin System',
        'action': 'USER_BLOCKED',
        'submissionId': 'user_4',
        'time': '2 hours ago',
        'notes': 'Blocked due to suspicious repetitive evidence upload.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Audit Logs'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockAuditLogs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = mockAuditLogs[index];
          final isApprove = log['action'] == 'APPROVED';
          final isReject = log['action'] == 'REJECTED';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log['action']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isApprove ? AppColors.success : (isReject ? AppColors.danger : AppColors.warning),
                      ),
                    ),
                    Text(
                      log['time']!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Actor: ${log['officer']}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Target Ref: ${log['submissionId']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Notes: ${log['notes']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
