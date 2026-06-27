export type PrescriptionStatus = "pending" | "analyzed" | "reviewed" | "dispensed" | "rejected";
export type SafetySeverity = "info" | "warning" | "critical";

export interface SafetyFlag {
  type: string;
  severity: SafetySeverity;
  message_ar: string;
}

export interface PrescriptionItem {
  id: number;
  extracted_medication_name: string;
  matched_medication_id: number | null;
  dosage_text: string | null;
  frequency_text: string | null;
  duration_text: string | null;
  confidence_score: number;
  pharmacist_confirmed: boolean;
}

export interface Prescription {
  id: number;
  customer_id: number;
  pharmacist_id: number | null;
  image_path: string;
  raw_ocr_text: string | null;
  status: PrescriptionStatus;
  pharmacist_notes: string | null;
  created_at: string;
  reviewed_at: string | null;
  items: PrescriptionItem[];
}

export interface PrescriptionAnalysisResult {
  prescription: Prescription;
  safety_flags: SafetyFlag[];
  disclaimer_ar: string;
}

export interface PrescriptionReviewPayload {
  status: PrescriptionStatus;
  pharmacist_notes?: string;
}

export interface PrescriptionItemUpdatePayload {
  matched_medication_id?: number | null;
  dosage_text?: string;
  frequency_text?: string;
  duration_text?: string;
  pharmacist_confirmed?: boolean;
}
