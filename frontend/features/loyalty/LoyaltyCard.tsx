import { Award, Gift } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import type { LoyaltyAccount } from "@/types";

const TIER_THRESHOLDS: Record<string, { next: number; nextLabel: string }> = {
  bronze: { next: 500, nextLabel: "الفضية" },
  silver: { next: 2000, nextLabel: "الذهبية" },
  gold: { next: 2000, nextLabel: "الذهبية" },
};

const TIER_LABELS_AR: Record<string, string> = { bronze: "البرونزية", silver: "الفضية", gold: "الذهبية" };

export function LoyaltyCard({ account }: { account: LoyaltyAccount }) {
  const threshold = TIER_THRESHOLDS[account.tier] ?? TIER_THRESHOLDS.bronze;
  const progressPct = account.tier === "gold" ? 100 : Math.min(100, (account.points / threshold.next) * 100);

  return (
    <Card className="overflow-hidden">
      <div className="bg-gradient-to-l from-primary to-secondary p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm opacity-90">نقاط الولاء</p>
            <p className="font-display text-3xl font-bold">{account.points}</p>
          </div>
          <Award className="h-10 w-10 opacity-90" />
        </div>
      </div>
      <CardContent className="space-y-3 p-5">
        <div className="flex items-center justify-between text-sm">
          <span className="font-semibold">الفئة: {TIER_LABELS_AR[account.tier] ?? account.tier}</span>
          {account.tier !== "gold" && (
            <span className="text-muted-foreground">حتى الفئة {threshold.nextLabel}</span>
          )}
        </div>
        <Progress value={progressPct} />
        <p className="flex items-center gap-2 text-xs text-muted-foreground">
          <Gift className="h-3.5 w-3.5" /> تُمنح النقاط تلقائيًا مع كل عملية شراء، ويمكن استبدالها بخصومات لاحقًا.
        </p>
      </CardContent>
    </Card>
  );
}
