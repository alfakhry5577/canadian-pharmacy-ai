export interface Alert {
  id: number;
  type: string;
  severity: "info" | "warning" | "critical";
  related_medication_id: number | null;
  related_prescription_id: number | null;
  customer_id: number | null;
  message_ar: string;
  is_resolved: boolean;
  created_at: string;
}

export interface TopMedicationStat {
  medication_id: number;
  name_ar: string;
  total_quantity_sold: number;
  total_revenue: string;
}

export interface SalesSummary {
  period_label: string;
  total_orders: number;
  total_revenue: string;
  top_medications: TopMedicationStat[];
  low_stock_count: number;
  expiring_soon_count: number;
}

export interface Reminder {
  id: number;
  medication_id: number;
  frequency_days: number;
  next_reminder_date: string;
  is_active: boolean;
}

export interface ReminderCreatePayload {
  medication_id: number;
  frequency_days?: number;
}

export interface LoyaltyAccount {
  id: number;
  customer_id: number;
  points: number;
  tier: string;
}

export type ChatRole = "user" | "assistant" | "system";

export interface ChatMessage {
  id: number;
  role: ChatRole;
  content: string;
  created_at: string;
}

export interface ChatReply {
  session_id: number;
  reply: ChatMessage;
  escalate_to_pharmacist: boolean;
}

export interface ApiErrorShape {
  detail: string | { msg: string }[];
}
