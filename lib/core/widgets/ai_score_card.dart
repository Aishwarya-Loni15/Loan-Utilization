import 'package:flutter/material.dart';
import '../../data/models/ai_analysis_model.dart';
import '../../app/theme/app_colors.dart';
import 'status_chip.dart';

class AiScoreCard extends StatelessWidget {
  final AiAnalysisModel aiAnalysis;

  const AiScoreCard({super.key, required this.aiAnalysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.aiBadgeGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'AI Verification Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              RiskLevelChip(level: aiAnalysis.riskLevel, isCompact: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                aiAnalysis.aiScore.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const Text(
                ' / 100',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: aiAnalysis.aiScore / 100,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                aiAnalysis.aiScore >= 90
                    ? Colors.lightGreenAccent
                    : (aiAnalysis.aiScore >= 70 ? Colors.amberAccent : Colors.orangeAccent),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Bank Manager Verification Badges: Image & Geotag Authenticity
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: aiAnalysis.isAiGenerated
                        ? Colors.purple.shade900.withValues(alpha: 0.9)
                        : (aiAnalysis.isImageReal
                            ? Colors.green.shade800.withValues(alpha: 0.7)
                            : Colors.red.shade900.withValues(alpha: 0.8)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        aiAnalysis.isAiGenerated
                            ? Icons.smart_toy_rounded
                            : (aiAnalysis.isImageReal ? Icons.verified_rounded : Icons.gpp_bad_rounded),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          aiAnalysis.isAiGenerated
                              ? 'Image: FAKE (AI Gen)'
                              : (aiAnalysis.isImageReal ? 'Image: REAL' : 'Image: FAKE'),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: aiAnalysis.isGeotagReal ? Colors.green.shade800.withValues(alpha: 0.7) : Colors.red.shade900.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(aiAnalysis.isGeotagReal ? Icons.location_on_rounded : Icons.wrong_location_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          aiAnalysis.isGeotagReal ? 'Geotag: REAL' : 'Geotag: FAKE',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Bank Manager AI Diagnostic Findings:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...aiAnalysis.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3.0, right: 8.0),
                    child: Icon(Icons.check_circle_rounded, color: Colors.white70, size: 14),
                  ),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
