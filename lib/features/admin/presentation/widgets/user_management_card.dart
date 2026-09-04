import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/user_model.dart';
import '../../../locations/presentation/widgets/geographical_hierarchy_badge.dart';

class UserManagementCardWidget extends StatelessWidget {
  final UserModel user;
  final ValueChanged<bool> onToggleBlock;

  const UserManagementCardWidget({
    super.key,
    required this.user,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: user.isBlocked ? AppColors.danger : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: user.isBlocked ? AppColors.danger.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                child: Icon(
                  user.isBlocked ? Icons.block_rounded : Icons.person_rounded,
                  color: user.isBlocked ? AppColors.danger : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${user.role.displayName} • ${user.email}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: user.isBlocked,
                activeThumbColor: AppColors.danger,
                onChanged: onToggleBlock,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GeographicalHierarchyBadge(
            state: user.state,
            district: user.district,
            taluka: user.taluka,
            village: user.village,
            compact: true,
          ),
        ],
      ),
    );
  }
}
