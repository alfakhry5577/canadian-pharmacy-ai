import { DollarSign, Package, AlertTriangle, ShoppingBag } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { SalesSummary } from "@/types";

function StatCard({ icon: Icon, label, value, tone }: { icon: any; label: string; value: string; tone?: "default" | "warning" | "destructive" }) {
  const toneClass =
    tone === "warning" ? "bg-warning/10 text-warning" : tone === "destructive" ? "bg-destructive/10 text-destructive" : "bg-primary/10 text-primary";
  return (
    <Card>
      <CardContent className="flex items-center gap-4 p-5">
        <div className={`rounded-xl p-3 ${toneClass}`}>
          <Icon className="h-5 w-5" />
        </div>
        <div>
          <p className="text-xs text-muted-foreground">{label}</p>
          <p className="font-display text-xl font-bold">{value}</p>
        </div>
      </CardContent>
    </Card>
  );
}

export function SalesSummaryCards({ summary }: { summary: SalesSummary }) {
  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <StatCard icon={DollarSign} label={`الإيرادات (${summary.period_label})`} value={formatCurrency(summary.total_revenue)} />
      <StatCard icon={ShoppingBag} label="عدد الطلبات" value={summary.total_orders.toString()} />
      <StatCard icon={Package} label="مخزون منخفض" value={summary.low_stock_count.toString()} tone="warning" />
      <StatCard icon={AlertTriangle} label="دفعات قاربت الانتهاء" value={summary.expiring_soon_count.toString()} tone="destructive" />
    </div>
  );
}
