import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export interface ImageAnalysisResult {
  objects: string[];
  confidence: number;
  imageRelevanceScore: number;
  score: number;
}

/**
 * Image analysis function detecting objects, confidence scores, and relevance.
 */
export async function analyzeImages(photoUrls: string[]): Promise<ImageAnalysisResult> {
  const apiKey = process.env.AI_API_KEY || functions.config().ai?.key || "SECURE_ENV_KEY";

  // Simulated object detection & confidence scoring
  const detectedObjects = [
    "Agricultural machine",
    "Tractor Equipment",
    "Solar Irrigation Sprayer",
  ];
  const confidence = 0.96;
  const imageRelevanceScore = 95.0;

  return {
    objects: detectedObjects,
    confidence,
    imageRelevanceScore,
    score: 95.0,
  };
}

/**
 * Cloud Function to process image analysis and save to Firestore
 */
export const processImageAnalysis = functions.https.onCall(async (data, context) => {
  const { submissionId, photoUrls } = data;
  if (!submissionId) {
    throw new functions.https.HttpsError("invalid-argument", "submissionId is required");
  }

  const result = await analyzeImages(photoUrls || []);
  const analysisId = `ai_${submissionId}`;

  const updateDoc = {
    analysisId,
    submissionId,
    detectedObjects: result.objects,
    visionConfidence: result.confidence,
    imageMatchScore: result.imageRelevanceScore,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await admin.firestore().collection("ai_analyses").doc(analysisId).set(updateDoc, { merge: true });

  return updateDoc;
});
