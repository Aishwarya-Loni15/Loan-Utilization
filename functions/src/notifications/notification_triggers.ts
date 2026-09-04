import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Send FCM push notification and log record to notifications collection
 */
async function sendNotification(
  userId: string,
  title: string,
  body: string,
  type: string,
  targetId?: string
) {
  const db = admin.firestore();

  // 1. Create notification document in Firestore: notifications/{notifId}
  const notifRef = db.collection("notifications").doc();
  const notificationDoc = {
    id: notifRef.id,
    userId,
    title,
    body,
    type,
    targetId: targetId || null,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await notifRef.set(notificationDoc);

  // 2. Fetch user's FCM push token if available
  const userDoc = await db.collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;

  if (fcmToken) {
    try {
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: {
          type,
          targetId: targetId || "",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    } catch (error) {
      console.error(`Failed to send FCM token push to user ${userId}:`, error);
    }
  }
}

/**
 * Trigger 1: Submission Uploaded
 */
export const onSubmissionCreated = functions.firestore
  .document("submissions/{submissionId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    await sendNotification(
      data.beneficiaryId,
      "Utilization Evidence Submitted",
      `Your evidence for ₹${data.amountSpent} has been uploaded successfully and sent for verification.`,
      "SUBMISSION_UPLOADED",
      context.params.submissionId
    );
  });

/**
 * Trigger 2: AI Completed
 */
export const onAiAnalysisCreated = functions.firestore
  .document("ai_analyses/{analysisId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return;

    const subDoc = await admin.firestore().collection("submissions").doc(data.submissionId).get();
    const beneficiaryId = subDoc.data()?.beneficiaryId;

    if (beneficiaryId) {
      await sendNotification(
        beneficiaryId,
        "AI Diagnostic Completed",
        `AI verification score generated: ${data.aiScore}/100 (${data.riskLevel} Risk).`,
        "AI_COMPLETED",
        data.submissionId
      );
    }
  });

/**
 * Trigger 3, 4, 5: Officer Action (Approved, Rejected, More Info Requested)
 */
export const onSubmissionStatusUpdated = functions.firestore
  .document("submissions/{submissionId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after || before.status === after.status) return;

    const beneficiaryId = after.beneficiaryId;
    const submissionId = context.params.submissionId;

    if (after.status === "APPROVED") {
      await sendNotification(
        beneficiaryId,
        "Utilization Claim Approved",
        "Your submitted loan utilization evidence has been verified and approved by the State Officer.",
        "APPROVED",
        submissionId
      );
    } else if (after.status === "REJECTED") {
      await sendNotification(
        beneficiaryId,
        "Submission Discrepancy Flagged",
        `Evidence package was rejected: ${after.rejectionReason || "Requirements not met."}`,
        "REJECTED",
        submissionId
      );
    } else if (after.status === "PENDING_MORE_INFO") {
      await sendNotification(
        beneficiaryId,
        "More Information Required",
        `Verification Officer requested details: ${after.requestComment || "Please upload additional vouchers."}`,
        "MORE_INFO_REQUESTED",
        submissionId
      );
    }
  });

/**
 * Trigger 6: Loan Status Changed
 */
export const onLoanStatusUpdated = functions.firestore
  .document("loans/{loanId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after || before.status === after.status) return;

    await sendNotification(
      after.beneficiaryId,
      "Loan Account Status Updated",
      `Your loan status changed from ${before.status} to ${after.status}.`,
      "LOAN_STATUS_CHANGED",
      context.params.loanId
    );
  });

/**
 * Trigger 7: Officer Assigned
 */
export const onOfficerAssigned = functions.firestore
  .document("submissions/{submissionId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after) return;
    if (!before.reviewedBy && after.reviewedBy) {
      await sendNotification(
        after.beneficiaryId,
        "Verification Officer Assigned",
        `State Officer ${after.reviewedBy} has been assigned to audit your submission.`,
        "OFFICER_ASSIGNED",
        context.params.submissionId
      );
    }
  });
