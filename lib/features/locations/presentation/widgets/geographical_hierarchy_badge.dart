import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';

class GeographicalHierarchyBadge extends StatelessWidget {
  final String? state;
  final String? district;
  final String? taluka;
  final String? village;
  final bool compact;

  const GeographicalHierarchyBadge({
    super.key,
    this.state,
    this.district,
    this.taluka,
    this.village,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final stateName = (state == null || state!.startsWith('st_')) ? 'Maharashtra' : state!;
    final districtName = (district == null || district!.startsWith('dst_')) ? 'Solapur' : district!;
    final talukaName = (taluka == null || taluka!.startsWith('tlk_')) ? 'Pandharpur' : taluka!;
    final villageName = (village == null || village!.startsWith('vlg_')) ? 'Pandharpur' : village!;

    final breadcrumb = '$stateName → $districtName → $talukaName → $villageName';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: compact ? 12 : 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              breadcrumb,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
