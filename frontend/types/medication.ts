export interface ActiveIngredient {
  id: number;
  name_en: string;
  name_ar: string;
}

export interface Medication {
  id: number;
  name_en: string;
  name_ar: string;
  dosage_form: string | null;
  strength: string | null;
  manufacturer: string | null;
  requires_prescription: boolean;
  price: string;
  general_usage: string | null;
  general_warnings: string | null;
  pregnancy_warning: string | null;
  pediatric_warning: string | null;
  elderly_warning: string | null;
  active_ingredient: ActiveIngredient | null;
}

export interface MedicationSearchResult {
  medication: Medication;
  in_stock: boolean;
  quantity_available: number;
  substitutes: Medication[];
}

export interface MedicationCreatePayload {
  name_en: string;
  name_ar: string;
  active_ingredient_id?: number | null;
  dosage_form?: string;
  strength?: string;
  manufacturer?: string;
  requires_prescription?: boolean;
  price: number;
  general_usage?: string;
  general_warnings?: string;
}

export interface InventoryItem {
  id: number;
  medication_id: number;
  quantity: number;
  reorder_threshold: number;
  batch_no: string | null;
  expiry_date: string | null;
  is_low_stock: boolean;
}

export interface InventoryUpdatePayload {
  quantity?: number;
  reorder_threshold?: number;
  batch_no?: string;
  expiry_date?: string;
}
