import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const reviewSubmissionFunction = functions.https.onCall(async (data, context) => {
  const { submissionId, action, reason, comment, officerId, officerName } = data;

  if (!submissionId || !action) {
    throw new functions.https.HttpsError("invalid-argument", "submissionId and action are required");
  }

  if (action === "REJECT" && (!reason || reason.trim().length === 0)) {
    throw new functions.https.HttpsError("invalid-argument", "Rejection requires a valid reason.");
  }

  if (action === "REQUEST_INFO" && (!comment || comment.trim().length === 0)) {
    throw new functions.https.HttpsError("invalid-argument", "Requesting more information requires a comment.");
  }

  const db = admin.firestore();
  const submissionRef = db.collection("submissions").doc(submissionId);
  const submissionDoc = await submissionRef.get();

  if (!submissionDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Submission record not found.");
  }

  let newStatus = "UNDER_REVIEW";
  if (action === "APPROVE") {
    newStatus = "APPROVED";
  } else if (action === "REJECT") {
    newStatus = "REJECTED";
  } else if (action === "REQUEST_INFO") {
    newStatus = "PENDING_MORE_INFO";
  }

  const now = admin.firestore.FieldValue.serverTimestamp();

  // Update submission status
  await submissionRef.update({
    status: newStatus,
    reviewedBy: officerName || "Officer",
    reviewedAt: now,
    rejectionReason: action === "REJECT" ? reason : null,
    requestComment: action === "REQUEST_INFO" ? comment : null,
    updatedAt: now,
  });

  // Create immutable Audit Log entry
  const auditLogId = `audit_${submissionId}_${Date.now()}`;
  const auditLogDoc = {
    auditLogId,
    submissionId,
    officerId: officerId || context.auth?.uid || "officer_system",
    officerName: officerName || "Verification Officer",
    action,
    previousStatus: submissionDoc.data()?.status || "UNKNOWN",
    newStatus,
    reason: reason || null,
    comment: comment || null,
    timestamp: now,
  };

  await db.collection("audit_logs").doc(auditLogId).set(auditLogDoc);

  return {
    success: true,
    submissionId,
    newStatus,
    auditLogId,
  };
});
