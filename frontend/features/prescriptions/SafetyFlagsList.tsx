import { ShieldCheck } from "lucide-react";
import { Callout } from "@/components/ui/callout";
import type { SafetyFlag } from "@/types";

export function SafetyFlagsList({ flags, disclaimer }: { flags: SafetyFlag[]; disclaimer?: string }) {
  return (
    <div className="space-y-3">
      {flags.length === 0 ? (
        <Callout variant="info">
          <span className="flex items-center gap-2">
            <ShieldCheck className="h-4 w-4" /> لم يرصد النظام تعارضات أو تحذيرات واضحة في هذه الوصفة — مع ذلك، تبقى
            المراجعة النهائية من الصيدلاني ضرورية.
          </span>
        </Callout>
      ) : (
        flags.map((flag, i) => (
          <Callout key={i} variant={flag.severity}>
            {flag.message_ar}
          </Callout>
        ))
      )}

      {disclaimer && (
        <p className="rounded-lg bg-muted px-4 py-3 text-xs leading-relaxed text-muted-foreground">{disclaimer}</p>
      )}
    </div>
  );
}
