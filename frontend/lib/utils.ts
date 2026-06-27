import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/** Merge Tailwind classes safely (shadcn/ui convention). */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/** Formats a decimal-string price (as returned by the API) as Libyan Dinar currency, Arabic locale. */
export function formatCurrency(value: string | number): string {
  const num = typeof value === "string" ? parseFloat(value) : value;
  if (Number.isNaN(num)) return "-";
  return new Intl.NumberFormat("ar-LY", { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(num) + " د.ل";
}

/** Formats an ISO date string using the Arabic locale. */
export function formatDate(iso: string | null | undefined): string {
  if (!iso) return "-";
  try {
    return new Intl.DateTimeFormat("ar-LY", { dateStyle: "medium", timeStyle: "short" }).format(new Date(iso));
  } catch {
    return iso;
  }
}

export function formatDateOnly(iso: string | null | undefined): string {
  if (!iso) return "-";
  try {
    return new Intl.DateTimeFormat("ar-LY", { dateStyle: "medium" }).format(new Date(iso));
  } catch {
    return iso;
  }
}

/** Clamp a 0..1 confidence score to a 0..100 percentage for display. */
export function confidenceToPercent(score: number): number {
  return Math.round(Math.min(1, Math.max(0, score)) * 100);
}

export function initials(fullName: string): string {
  const parts = fullName.trim().split(/\s+/);
  return parts.slice(0, 2).map((p) => p[0]).join("");
}

/** Builds a viewable URL for a prescription image from the backend-stored path (e.g. "./uploads/abc.jpg"). */
export function prescriptionImageUrl(imagePath: string): string {
  const filename = imagePath.split(/[\\/]/).pop();
  const base = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";
  return `${base}/uploads/${filename}`;
}
