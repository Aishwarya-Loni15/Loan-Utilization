import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export interface PurposeMatchResult {
  matched: boolean;
  matchRating: "HIGH" | "MEDIUM" | "LOW";
  purposeMatchScore: number;
  reasoning: string;
}

/**
 * Compare loan purpose vs detected objects/OCR text.
 * Example:
 * Loan purpose: "Agricultural equipment"
 * Detected: "Agricultural machine"
 * Result: purposeMatchScore = HIGH (95.0)
 */
export async function matchPurpose(
  loanPurpose: string,
  detectedTextOrObjects: string
): Promise<PurposeMatchResult> {
  if (!loanPurpose || loanPurpose.trim().length === 0) {
    return {
      matched: true,
      matchRating: "HIGH",
      purposeMatchScore: 90.0,
      reasoning: "General purpose matching defaulted to HIGH match rating.",
    };
  }

  const pLower = loanPurpose.toLowerCase();
  const dLower = detectedTextOrObjects.toLowerCase();

  // Match keyword evaluation
  const isAgriMatch =
    (pLower.includes("agri") || pLower.includes("tractor") || pLower.includes("farm")) &&
    (dLower.includes("agri") || dLower.includes("machine") || dLower.includes("tractor") || dLower.includes("sprayer"));

  if (isAgriMatch || pLower === dLower) {
    return {
      matched: true,
      matchRating: "HIGH",
      purposeMatchScore: 95.0,
      reasoning: `Loan purpose '${loanPurpose}' matched detected '${detectedTextOrObjects}' with HIGH rating.`,
    };
  }

  const wordMatch = pLower.split(" ").some((w) => w.length > 3 && dLower.includes(w));
  if (wordMatch) {
    return {
      matched: true,
      matchRating: "MEDIUM",
      purposeMatchScore: 75.0,
      reasoning: `Partial match between loan purpose '${loanPurpose}' and detected evidence.`,
    };
  }

  return {
    matched: false,
    matchRating: "LOW",
    purposeMatchScore: 40.0,
    reasoning: `Discrepancy detected between loan purpose '${loanPurpose}' and evidence '${detectedTextOrObjects}'.`,
  };
}

/**
 * Cloud Function for purpose matching evaluation saved to Firestore
 */
export const processPurposeMatch = functions.https.onCall(async (data, context) => {
  const { submissionId, loanPurpose, detectedTextOrObjects } = data;
  if (!submissionId) {
    throw new functions.https.HttpsError("invalid-argument", "submissionId is required");
  }

  const result = await matchPurpose(loanPurpose || "", detectedTextOrObjects || "");
  const analysisId = `ai_${submissionId}`;

  const updateDoc = {
    analysisId,
    submissionId,
    purposeMatchScore: result.purposeMatchScore,
    purposeMatchRating: result.matchRating,
    purposeMatchReasoning: result.reasoning,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await admin.firestore().collection("ai_analyses").doc(analysisId).set(updateDoc, { merge: true });

  return updateDoc;
});
