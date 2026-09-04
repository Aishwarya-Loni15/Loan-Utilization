import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { performInvoiceOcr } from "./invoice_ocr";
import { analyzeImages } from "./image_analysis";
import { matchPurpose } from "./purpose_matching";
import { calculateRiskScore } from "./risk_score";

export const analyzeSubmission = functions.https.onCall(async (data, context) => {
  const submissionId = data.submissionId;
  if (!submissionId) {
    throw new functions.https.HttpsError("invalid-argument", "submissionId is required");
  }

  const ocrResult = await performInvoiceOcr(data.documentUrl, data.loanPurpose);
  const imageResult = await analyzeImages(data.photoUrls || []);
  const purposeResult = await matchPurpose(
    data.loanPurpose || "Agricultural equipment",
    imageResult.objects.join(", ")
  );

  const amountMatchScore =
    ocrResult.extractedAmount && data.claimedAmount
      ? Math.abs(ocrResult.extractedAmount - data.claimedAmount) < 100
        ? 95.0
        : 70.0
      : 90.0;

  const locationScore = data.isGeotagValid ? 98.0 : 85.0;
  const duplicateScore = data.isDuplicate ? 80.0 : 0.0;

  const riskResult = calculateRiskScore({
    purposeMatchScore: purposeResult.purposeMatchScore,
    invoiceMatchScore: ocrResult.ocrScore,
    imageMatchScore: imageResult.imageRelevanceScore,
    amountMatchScore,
    locationScore,
    duplicateScore,
  });

  const analysisId = `ai_${submissionId}`;

  const analysisDoc = {
    analysisId,
    submissionId,
    aiScore: riskResult.aiScore,
    riskLevel: riskResult.riskLevel,
    purposeMatchScore: purposeResult.purposeMatchScore,
    invoiceMatchScore: ocrResult.ocrScore,
    imageMatchScore: imageResult.imageRelevanceScore,
    amountMatchScore,
    locationScore,
    duplicateScore,
    extractedVendor: ocrResult.vendor,
    extractedInvoiceNumber: ocrResult.invoiceNumber,
    extractedDate: ocrResult.date,
    extractedProduct: ocrResult.product,
    extractedInvoiceAmount: ocrResult.amount,
    extractedTax: ocrResult.tax,
    purposeMatch: ocrResult.purposeMatch,
    detectedObjects: imageResult.objects,
    detectedText: `${ocrResult.vendor} ${ocrResult.invoiceNumber} ${ocrResult.product}`,
    reasons: riskResult.reasons,
    disclaimer: riskResult.disclaimer,
    analyzedAt: new Date().toISOString(),
  };

  // Store all results in Firestore: ai_analyses/{analysisId}
  await admin.firestore().collection("ai_analyses").doc(analysisId).set(analysisDoc, { merge: true });

  return analysisDoc;
});
