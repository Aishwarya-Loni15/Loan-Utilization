export interface RiskScoreInput {
  purposeMatchScore: number;
  invoiceMatchScore: number;
  imageMatchScore: number;
  amountMatchScore: number;
  locationScore: number;
  duplicateScore: number;
}

export interface RiskScoreOutput {
  aiScore: number;
  riskLevel: "LOW" | "MEDIUM" | "HIGH";
  reasons: string[];
  disclaimer: string;
}

/**
 * Calculates composite risk score and risk level for loan utilization submissions.
 * Weights:
 * - purposeMatchScore (25%)
 * - invoiceMatchScore (25%)
 * - imageMatchScore (20%)
 * - amountMatchScore (15%)
 * - locationScore (15%)
 * - duplicateScore (penalty up to -30 points)
 *
 * Risk Level Scale:
 * - 90 - 100: LOW
 * - 70 - 89:  MEDIUM
 * - 0  - 69:  HIGH
 *
 * NOTE: AI is an assistive tool providing risk insights. AI is NOT the final decision maker.
 */
export function calculateRiskScore(input: RiskScoreInput): RiskScoreOutput {
  const {
    purposeMatchScore,
    invoiceMatchScore,
    imageMatchScore,
    amountMatchScore,
    locationScore,
    duplicateScore,
  } = input;

  // Base weighted score calculation
  let weightedScore =
    purposeMatchScore * 0.25 +
    invoiceMatchScore * 0.25 +
    imageMatchScore * 0.2 +
    amountMatchScore * 0.15 +
    locationScore * 0.15;

  // Apply duplicate detection penalty if applicable
  if (duplicateScore > 0) {
    weightedScore = weightedScore - duplicateScore * 0.3;
  }

  const aiScore = Math.max(0, Math.min(100, Math.round(weightedScore * 10) / 10));

  // Determine Risk Level according to strict thresholds
  let riskLevel: "LOW" | "MEDIUM" | "HIGH" = "LOW";
  if (aiScore >= 90) {
    riskLevel = "LOW";
  } else if (aiScore >= 70) {
    riskLevel = "MEDIUM";
  } else {
    riskLevel = "HIGH";
  }

  // Generate detailed diagnostic reasons
  const reasons: string[] = [];

  reasons.push(
    `Assistive Composite Score: ${aiScore}/100 resulting in ${riskLevel} risk assessment.`
  );

  if (purposeMatchScore >= 90) {
    reasons.push("Loan Purpose Match: High alignment with scheme guidelines.");
  } else if (purposeMatchScore < 70) {
    reasons.push("Loan Purpose Warning: Potential discrepancy between purpose and evidence.");
  }

  if (invoiceMatchScore >= 90) {
    reasons.push("Invoice Verification: OCR extracted valid vendor and receipt details.");
  } else if (invoiceMatchScore < 70) {
    reasons.push("Invoice Warning: Unclear or unverified receipt details.");
  }

  if (locationScore >= 90) {
    reasons.push("Geotag Lock: GPS location confirmed within registered village boundary.");
  } else if (locationScore < 70) {
    reasons.push("Geotag Warning: GPS location captured outside designated boundary.");
  }

  if (duplicateScore > 20) {
    reasons.push("Duplicate Flag: Similar evidence photo detected in past submissions.");
  }

  const disclaimer =
    "AI evaluation is purely assistive. Final approval or rejection authority rests with human verification officers.";

  return {
    aiScore,
    riskLevel,
    reasons,
    disclaimer,
  };
}

/**
 * Legacy compatibility wrapper function
 */
export function calculateRisk(
  purposeScore: number,
  invoiceScore: number,
  imageScore: number,
  locationScore: number
): { aiScore: number; riskLevel: "LOW" | "MEDIUM" | "HIGH" } {
  const result = calculateRiskScore({
    purposeMatchScore: purposeScore,
    invoiceMatchScore: invoiceScore,
    imageMatchScore: imageScore,
    amountMatchScore: 90.0,
    locationScore: locationScore,
    duplicateScore: 0.0,
  });

  return {
    aiScore: result.aiScore,
    riskLevel: result.riskLevel,
  };
}
