/**
 * LOANLENS — Firestore Security Rules Test Suite
 *
 * Run with:
 *   npx firebase-tools emulators:exec --only firestore \
 *     "npx mocha --timeout 15000 firebase/firestore.rules.test.js"
 *
 * Or start the emulator separately and run:
 *   npx mocha --timeout 15000 firebase/firestore.rules.test.js
 *
 * Requires:
 *   npm install --save-dev @firebase/rules-unit-testing mocha chai
 */

const { initializeTestEnvironment, assertFails, assertSucceeds } =
  require("@firebase/rules-unit-testing");
const { readFileSync } = require("fs");
const { resolve } = require("path");
const { describe, before, after, beforeEach, it } = require("mocha");
const assert = require("assert");

// ─── Test User Profiles ──────────────────────────────────────────────────────

const ADMIN_UID        = "admin-001";
const OFFICER_UID      = "officer-001";
const BANK_MGR_UID     = "bank-mgr-001";
const BENEFICIARY_UID  = "beneficiary-001";
const BENEFICIARY2_UID = "beneficiary-002";
const PROJECT_ID       = "loanlens-test";

// Firestore user documents (Firestore data, not Auth tokens)
const ADMIN_DOC = {
  uid: ADMIN_UID, name: "Admin User", email: "admin@loanlens.in",
  role: "ADMIN", districtId: "D01", stateId: "S01", bankId: null, isBlocked: false,
};
const OFFICER_DOC = {
  uid: OFFICER_UID, name: "State Officer", email: "officer@loanlens.in",
  role: "STATE_OFFICER", districtId: "D01", stateId: "S01", bankId: null, isBlocked: false,
};
const BANK_MGR_DOC = {
  uid: BANK_MGR_UID, name: "Bank Manager", email: "bank@loanlens.in",
  role: "BANK_MANAGER", districtId: "D01", stateId: "S01", bankId: "BANK01", isBlocked: false,
};
const BENEFICIARY_DOC = {
  uid: BENEFICIARY_UID, name: "Ramesh Kumar", email: "ramesh@gmail.com",
  role: "BENEFICIARY", districtId: "D01", stateId: "S01", bankId: null, isBlocked: false,
};
const BENEFICIARY2_DOC = {
  uid: BENEFICIARY2_UID, name: "Sunita Patel", email: "sunita@gmail.com",
  role: "BENEFICIARY", districtId: "D02", stateId: "S01", bankId: null, isBlocked: false,
};

// Sample collection documents
const LOAN_DOC = {
  loanId: "LOAN01", beneficiaryId: BENEFICIARY_UID, bankId: "BANK01",
  districtId: "D01", status: "ACTIVE", schemeName: "Agri Scheme",
  sanctionedAmount: 100000, disbursedAmount: 80000, utilizedAmount: 0,
  createdAt: "2025-01-01T00:00:00Z", updatedAt: "2025-01-01T00:00:00Z",
};
const SUBMISSION_DOC = {
  submissionId: "SUB01", loanId: "LOAN01",
  beneficiaryId: BENEFICIARY_UID, bankId: "BANK01", districtId: "D01",
  amountSpent: 50000, description: "Purchased tractor",
  latitude: 17.6868, longitude: 75.9011, locationAccuracy: 5.0,
  capturedAt: "2025-06-01T10:00:00Z", status: "pending", riskLevel: "LOW",
  createdAt: "2025-06-01T10:00:00Z", updatedAt: "2025-06-01T10:00:00Z",
};
const AI_DOC = {
  analysisId: "AI01", submissionId: "SUB01", beneficiaryId: BENEFICIARY_UID,
  aiScore: 94.0, riskLevel: "LOW", purposeMatchScore: 95, invoiceMatchScore: 92,
  imageMatchScore: 94, locationScore: 98, duplicateScore: 0,
  analyzedAt: "2025-06-01T10:05:00Z",
};
const AUDIT_DOC = {
  logId: "LOG01", userId: OFFICER_UID, role: "STATE_OFFICER",
  action: "APPROVE_SUBMISSION", targetId: "SUB01",
  description: "Approved submission SUB01", timestamp: "2025-06-01T11:00:00Z",
};
const NOTIFICATION_DOC = {
  userId: BENEFICIARY_UID, title: "Submission Approved",
  body: "Your submission has been approved.", type: "APPROVED",
  targetId: "SUB01", isRead: false, createdAt: "2025-06-01T11:00:00Z",
};

// ─── Test Environment ─────────────────────────────────────────────────────────

let testEnv;

function makeAuth(uid, tokenData = {}) {
  return { uid, ...tokenData };
}

async function getDb(auth) {
  if (auth) {
    return testEnv.authenticatedContext(auth.uid, auth).firestore();
  }
  return testEnv.unauthenticatedContext().firestore();
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(__dirname, "firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  // Seed Firestore with test data via admin (bypasses rules).
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc(`users/${ADMIN_UID}`).set(ADMIN_DOC);
    await db.doc(`users/${OFFICER_UID}`).set(OFFICER_DOC);
    await db.doc(`users/${BANK_MGR_UID}`).set(BANK_MGR_DOC);
    await db.doc(`users/${BENEFICIARY_UID}`).set(BENEFICIARY_DOC);
    await db.doc(`users/${BENEFICIARY2_UID}`).set(BENEFICIARY2_DOC);
    await db.doc("loans/LOAN01").set(LOAN_DOC);
    await db.doc("utilization_submissions/SUB01").set(SUBMISSION_DOC);
    await db.doc("ai_analyses/AI01").set(AI_DOC);
    await db.doc("audit_logs/LOG01").set(AUDIT_DOC);
    await db.doc("notifications/NOTIF01").set(NOTIFICATION_DOC);
    await db.doc("banks/BANK01").set({ bankId: "BANK01", name: "SBI Solapur" });
    await db.doc("states/S01").set({ stateId: "S01", name: "Maharashtra" });
    await db.doc("districts/D01").set({ districtId: "D01", name: "Solapur", stateId: "S01" });
    await db.doc("villages/V01").set({ villageId: "V01", name: "Pandharpur" });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════════════

describe("LoanLens — Firestore Security Rules", () => {

  // ─── Unauthenticated ────────────────────────────────────────────────────────

  describe("Unauthenticated access — must always fail", () => {
    it("❌ cannot read users", async () => {
      const db = await getDb(null);
      await assertFails(db.doc(`users/${BENEFICIARY_UID}`).get());
    });
    it("❌ cannot read loans", async () => {
      const db = await getDb(null);
      await assertFails(db.doc("loans/LOAN01").get());
    });
    it("❌ cannot read submissions", async () => {
      const db = await getDb(null);
      await assertFails(db.doc("utilization_submissions/SUB01").get());
    });
    it("❌ cannot read ai_analyses", async () => {
      const db = await getDb(null);
      await assertFails(db.doc("ai_analyses/AI01").get());
    });
    it("❌ cannot read audit_logs", async () => {
      const db = await getDb(null);
      await assertFails(db.doc("audit_logs/LOG01").get());
    });
    it("❌ cannot read notifications", async () => {
      const db = await getDb(null);
      await assertFails(db.doc("notifications/NOTIF01").get());
    });
  });

  // ─── BENEFICIARY ────────────────────────────────────────────────────────────

  describe("BENEFICIARY role", () => {
    let db;
    before(async () => { db = await getDb(makeAuth(BENEFICIARY_UID)); });

    // users
    it("✅ can read own user profile", async () => {
      await assertSucceeds(db.doc(`users/${BENEFICIARY_UID}`).get());
    });
    it("❌ cannot read another beneficiary's profile", async () => {
      await assertFails(db.doc(`users/${BENEFICIARY2_UID}`).get());
    });
    it("❌ cannot update own role", async () => {
      await assertFails(db.doc(`users/${BENEFICIARY_UID}`).update({ role: "ADMIN" }));
    });
    it("✅ can update own non-privileged fields", async () => {
      await assertSucceeds(db.doc(`users/${BENEFICIARY_UID}`).update({ address: "New Address" }));
    });
    it("❌ cannot delete own account", async () => {
      await assertFails(db.doc(`users/${BENEFICIARY_UID}`).delete());
    });

    // loans
    it("✅ can read own loan", async () => {
      await assertSucceeds(db.doc("loans/LOAN01").get());
    });
    it("❌ cannot create a loan", async () => {
      await assertFails(db.collection("loans").add({ ...LOAN_DOC, loanId: "LOAN99" }));
    });
    it("❌ cannot delete a loan", async () => {
      await assertFails(db.doc("loans/LOAN01").delete());
    });

    // submissions
    it("✅ can read own submission", async () => {
      await assertSucceeds(db.doc("utilization_submissions/SUB01").get());
    });
    it("✅ can create a submission for own loan", async () => {
      await assertSucceeds(db.collection("utilization_submissions").add({
        ...SUBMISSION_DOC,
        submissionId: "SUB_NEW",
        beneficiaryId: BENEFICIARY_UID,
        status: "pending",
      }));
    });
    it("❌ cannot create submission for another beneficiary", async () => {
      await assertFails(db.collection("utilization_submissions").add({
        ...SUBMISSION_DOC,
        beneficiaryId: BENEFICIARY2_UID,
        status: "pending",
      }));
    });
    it("❌ cannot create submission with status != pending", async () => {
      await assertFails(db.collection("utilization_submissions").add({
        ...SUBMISSION_DOC,
        beneficiaryId: BENEFICIARY_UID,
        status: "approved",
      }));
    });
    it("❌ cannot update own submission (review is for officers)", async () => {
      await assertFails(db.doc("utilization_submissions/SUB01").update({ status: "approved" }));
    });

    // ai_analyses — read-only for beneficiary (own)
    it("✅ can read own AI analysis", async () => {
      await assertSucceeds(db.doc("ai_analyses/AI01").get());
    });
    it("❌ cannot write to ai_analyses", async () => {
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });

    // audit_logs
    it("❌ cannot read audit logs", async () => {
      await assertFails(db.doc("audit_logs/LOG01").get());
    });
    it("❌ cannot update audit logs", async () => {
      await assertFails(db.doc("audit_logs/LOG01").update({ action: "TAMPERED" }));
    });
    it("❌ cannot delete audit logs", async () => {
      await assertFails(db.doc("audit_logs/LOG01").delete());
    });

    // notifications
    it("✅ can read own notifications", async () => {
      await assertSucceeds(db.doc("notifications/NOTIF01").get());
    });
    it("✅ can mark own notification as read", async () => {
      await assertSucceeds(db.doc("notifications/NOTIF01").update({ isRead: true }));
    });
    it("❌ cannot update other notification fields", async () => {
      await assertFails(db.doc("notifications/NOTIF01").update({ title: "Hacked" }));
    });
    it("❌ cannot create notifications (Cloud Functions only)", async () => {
      await assertFails(db.collection("notifications").add({ ...NOTIFICATION_DOC }));
    });

    // location reference data
    it("✅ can read states", async () => {
      await assertSucceeds(db.doc("states/S01").get());
    });
    it("✅ can read districts", async () => {
      await assertSucceeds(db.doc("districts/D01").get());
    });
    it("✅ can read banks", async () => {
      await assertSucceeds(db.doc("banks/BANK01").get());
    });
    it("❌ cannot write to location data", async () => {
      await assertFails(db.doc("states/S01").update({ name: "Hacked State" }));
    });
  });

  // ─── STATE OFFICER ──────────────────────────────────────────────────────────

  describe("STATE_OFFICER role", () => {
    let db;
    before(async () => { db = await getDb(makeAuth(OFFICER_UID)); });

    it("✅ can read user profiles", async () => {
      await assertSucceeds(db.doc(`users/${BENEFICIARY_UID}`).get());
    });
    it("✅ can read loans in assigned district", async () => {
      await assertSucceeds(db.doc("loans/LOAN01").get());
    });
    it("✅ can read submissions in assigned district", async () => {
      await assertSucceeds(db.doc("utilization_submissions/SUB01").get());
    });
    it("✅ can update submission status (review action)", async () => {
      await assertSucceeds(
        db.doc("utilization_submissions/SUB01").update({
          status: "approved", reviewedBy: OFFICER_UID,
          reviewedAt: "2025-06-01T12:00:00Z",
        })
      );
    });
    it("❌ cannot change immutable submission identity fields", async () => {
      await assertFails(
        db.doc("utilization_submissions/SUB01").update({ beneficiaryId: "HACKED" })
      );
    });
    it("✅ can read AI analyses", async () => {
      await assertSucceeds(db.doc("ai_analyses/AI01").get());
    });
    it("❌ cannot write to AI analyses", async () => {
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
    it("✅ can read audit logs", async () => {
      await assertSucceeds(db.doc("audit_logs/LOG01").get());
    });
    it("✅ can create audit log entries", async () => {
      await assertSucceeds(db.collection("audit_logs").add({
        userId: OFFICER_UID, role: "STATE_OFFICER",
        action: "APPROVE_SUBMISSION", targetId: "SUB01",
        description: "Approved", timestamp: "2025-06-01T12:00:00Z",
      }));
    });
    it("❌ cannot update existing audit logs (immutable)", async () => {
      await assertFails(db.doc("audit_logs/LOG01").update({ action: "TAMPERED" }));
    });
    it("❌ cannot delete audit logs (immutable)", async () => {
      await assertFails(db.doc("audit_logs/LOG01").delete());
    });
    it("❌ cannot create loans", async () => {
      await assertFails(db.collection("loans").add({ ...LOAN_DOC, loanId: "LOAN99" }));
    });
    it("❌ cannot write to location data", async () => {
      await assertFails(db.doc("districts/D01").update({ name: "Hacked" }));
    });
  });

  // ─── BANK MANAGER ───────────────────────────────────────────────────────────

  describe("BANK_MANAGER role", () => {
    let db;
    before(async () => { db = await getDb(makeAuth(BANK_MGR_UID)); });

    it("✅ can read loans for their bank", async () => {
      await assertSucceeds(db.doc("loans/LOAN01").get());
    });
    it("✅ can create a loan for their bank", async () => {
      await assertSucceeds(db.collection("loans").add({
        ...LOAN_DOC, loanId: "LOAN99", bankId: "BANK01",
      }));
    });
    it("❌ cannot create a loan for another bank", async () => {
      await assertFails(db.collection("loans").add({
        ...LOAN_DOC, loanId: "LOAN99", bankId: "OTHER_BANK",
      }));
    });
    it("✅ can update loan for their bank", async () => {
      await assertSucceeds(
        db.doc("loans/LOAN01").update({ disbursedAmount: 90000 })
      );
    });
    it("❌ cannot change immutable loan identity fields", async () => {
      await assertFails(
        db.doc("loans/LOAN01").update({ beneficiaryId: "HACKED" })
      );
    });
    it("❌ cannot delete loans", async () => {
      await assertFails(db.doc("loans/LOAN01").delete());
    });
    it("✅ can read submissions for their bank", async () => {
      await assertSucceeds(db.doc("utilization_submissions/SUB01").get());
    });
    it("✅ can update submission status", async () => {
      await assertSucceeds(
        db.doc("utilization_submissions/SUB01").update({ status: "underReview" })
      );
    });
    it("❌ cannot read audit logs (officer/admin only)", async () => {
      await assertFails(db.doc("audit_logs/LOG01").get());
    });
    it("❌ cannot write to ai_analyses", async () => {
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
  });

  // ─── ADMIN ──────────────────────────────────────────────────────────────────

  describe("ADMIN role", () => {
    let db;
    before(async () => { db = await getDb(makeAuth(ADMIN_UID)); });

    it("✅ can read any user", async () => {
      await assertSucceeds(db.doc(`users/${BENEFICIARY_UID}`).get());
    });
    it("✅ can update user role", async () => {
      await assertSucceeds(db.doc(`users/${BENEFICIARY_UID}`).update({ role: "STATE_OFFICER" }));
    });
    it("✅ can delete a user", async () => {
      await assertSucceeds(db.doc(`users/${BENEFICIARY2_UID}`).delete());
    });
    it("✅ can read any loan", async () => {
      await assertSucceeds(db.doc("loans/LOAN01").get());
    });
    it("✅ can delete a loan", async () => {
      // Re-seed first
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().doc("loans/LOAN01").set(LOAN_DOC);
      });
      await assertSucceeds(db.doc("loans/LOAN01").delete());
    });
    it("✅ can read any submission", async () => {
      await assertSucceeds(db.doc("utilization_submissions/SUB01").get());
    });
    it("✅ can delete a submission", async () => {
      await assertSucceeds(db.doc("utilization_submissions/SUB01").delete());
    });
    it("✅ can read audit logs", async () => {
      await assertSucceeds(db.doc("audit_logs/LOG01").get());
    });
    it("❌ admin cannot update audit logs (immutable even for admin via client SDK)", async () => {
      await assertFails(db.doc("audit_logs/LOG01").update({ action: "ADMIN_TAMPER" }));
    });
    it("❌ admin cannot delete audit logs (immutable via client SDK)", async () => {
      await assertFails(db.doc("audit_logs/LOG01").delete());
    });
    it("✅ can write location data", async () => {
      await assertSucceeds(db.doc("states/S99").set({ stateId: "S99", name: "Test State" }));
    });
    it("✅ can write banks", async () => {
      await assertSucceeds(db.doc("banks/BANK99").set({ bankId: "BANK99", name: "Test Bank" }));
    });
    it("❌ admin cannot write to ai_analyses via client SDK", async () => {
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
  });

  // ─── AI ANALYSES — global protection ────────────────────────────────────────

  describe("AI Analyses — immutable write protection", () => {
    it("❌ beneficiary cannot write ai_analyses", async () => {
      const db = await getDb(makeAuth(BENEFICIARY_UID));
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
    it("❌ officer cannot write ai_analyses", async () => {
      const db = await getDb(makeAuth(OFFICER_UID));
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
    it("❌ bank manager cannot write ai_analyses", async () => {
      const db = await getDb(makeAuth(BANK_MGR_UID));
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
    it("❌ admin cannot write ai_analyses via client SDK", async () => {
      const db = await getDb(makeAuth(ADMIN_UID));
      await assertFails(db.collection("ai_analyses").add({ ...AI_DOC }));
    });
  });

  // ─── Audit Logs — immutability ───────────────────────────────────────────────

  describe("Audit Logs — strict immutability", () => {
    it("❌ nobody can update an audit log entry", async () => {
      for (const uid of [ADMIN_UID, OFFICER_UID, BANK_MGR_UID, BENEFICIARY_UID]) {
        const db = await getDb(makeAuth(uid));
        await assertFails(db.doc("audit_logs/LOG01").update({ action: "TAMPERED" }));
      }
    });
    it("❌ nobody can delete an audit log entry", async () => {
      for (const uid of [ADMIN_UID, OFFICER_UID, BANK_MGR_UID, BENEFICIARY_UID]) {
        const db = await getDb(makeAuth(uid));
        await assertFails(db.doc("audit_logs/LOG01").delete());
      }
    });
  });

  // ─── Never allow if true ─────────────────────────────────────────────────────

  describe("Catch-all: unmatched paths must deny all", () => {
    it("❌ unauthenticated: random collection is denied", async () => {
      const db = await getDb(null);
      await assertFails(db.doc("someRandomCollection/doc1").get());
    });
    it("❌ authenticated: random unmatched collection is denied", async () => {
      const db = await getDb(makeAuth(ADMIN_UID));
      await assertFails(db.doc("secretCollection/doc1").get());
    });
    it("❌ authenticated: random unmatched write is denied", async () => {
      const db = await getDb(makeAuth(ADMIN_UID));
      await assertFails(db.doc("secretCollection/doc1").set({ data: "test" }));
    });
  });
});
