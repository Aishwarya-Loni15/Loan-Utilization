import * as admin from "firebase-admin";

admin.initializeApp();

export { analyzeSubmissionTrigger } from "./ai/analyze_submission";
