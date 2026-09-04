import 'dart:io';
import 'package:flutter/material.dart';
import 'package:laon/app/theme/app_colors.dart';
import 'package:laon/core/enums/risk_level.dart';
import 'package:laon/core/utils/currency_utils.dart';
import 'package:laon/core/utils/date_utils.dart';
import 'package:laon/core/services/location_service.dart';
import 'package:laon/domain/entities/utilization_submission.dart';

class GeotaggedSubmissionCard extends StatelessWidget {
  final UtilizationSubmissionEntity submission;
  final VoidCallback onTap;

  const GeotaggedSubmissionCard({
    super.key,
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = submission.photoUrls.isNotEmpty ? submission.photoUrls.first : '';
    final isHighRisk = submission.riskLevel == RiskLevel.high;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isHighRisk ? AppColors.danger : AppColors.primary.withValues(alpha: 0.2),
          width: isHighRisk ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Geotag Pill + Risk Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Geotagged Evidence',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRiskBadge(submission.riskLevel, submission.aiScore ?? 0.0),
                ],
              ),
              const SizedBox(height: 12),

              // Image + Submission Details Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geotag Image Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: (photoUrl.isNotEmpty && File(photoUrl).existsSync())
                          ? Image.file(
                              File(photoUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.network(
                                'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=400',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.network(
                              photoUrl.startsWith('http')
                                  ? photoUrl
                                  : 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=400',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.network(
                                'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=400',
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Claim: ${CurrencyUtils.formatINR(submission.amountSpent)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          submission.description.isNotEmpty
                              ? submission.description
                              : 'Beneficiary uploaded geotagged proof photo',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        FutureBuilder<LiveAddressResult>(
                          future: LocationService().getLiveAddress(submission.latitude, submission.longitude),
                          builder: (context, snapshot) {
                            final addr = snapshot.data;
                            final village = addr?.villageName ?? (submission.registeredVillage.isNotEmpty ? submission.registeredVillage : 'Ojewadi');
                            final district = addr?.districtName ?? 'Solapur District';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '📍 $village, $district',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.my_location_rounded, size: 11, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'GPS: ${submission.latitude.toStringAsFixed(4)}° N, ${submission.longitude.toStringAsFixed(4)}° E (±${submission.locationAccuracy.toStringAsFixed(1)}m)',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'Monospace',
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(height: 1),
              const SizedBox(height: 10),

              // Bottom Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.formatDateTime(submission.capturedAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        'Audit Geotag',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(RiskLevel risk, double score) {
    Color bg;
    Color fg;
    String label;

    switch (risk) {
      case RiskLevel.low:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Verified ${score.toStringAsFixed(0)}%';
        break;
      case RiskLevel.medium:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        label = 'Medium Risk';
        break;
      case RiskLevel.high:
        bg = AppColors.danger.withValues(alpha: 0.15);
        fg = AppColors.danger;
        label = 'High Risk Flag';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

