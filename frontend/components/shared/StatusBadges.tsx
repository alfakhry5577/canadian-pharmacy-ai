import { Badge } from "@/components/ui/badge";
import { PRESCRIPTION_STATUS_LABEL_AR, SAFETY_SEVERITY_LABEL_AR } from "@/lib/constants";
import type { PrescriptionStatus, SafetySeverity } from "@/types";

export function PrescriptionStatusBadge({ status }: { status: PrescriptionStatus }) {
  const variant =
    status === "rejected" ? "destructive" : status === "dispensed" ? "success" : status === "reviewed" ? "default" : "warning";
  return <Badge variant={variant as any}>{PRESCRIPTION_STATUS_LABEL_AR[status]}</Badge>;
}

export function SeverityBadge({ severity }: { severity: SafetySeverity }) {
  const variant = severity === "critical" ? "destructive" : severity === "warning" ? "warning" : "default";
  return <Badge variant={variant as any}>{SAFETY_SEVERITY_LABEL_AR[severity]}</Badge>;
}
