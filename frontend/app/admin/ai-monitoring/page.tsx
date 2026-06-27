import { MessageSquare, ShieldAlert, Gauge, TrendingUp } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { ScaffoldNotice } from "@/components/shared/ScaffoldNotice";
import { Card, CardContent } from "@/components/ui/card";

const MOCK_METRICS = [
  { icon: MessageSquare, label: "محادثات هذا الأسبوع", value: "—" },
  { icon: ShieldAlert, label: "نسبة التحويل للصيدلاني", value: "—" },
  { icon: Gauge, label: "متوسط زمن استجابة AI", value: "—" },
  { icon: TrendingUp, label: "دقة استخراج الوصفات (تقديرية)", value: "—" },
];

export default function AdminAIMonitoringPage() {
  return (
    <div>
      <PageHeader title="مراقبة الذكاء الاصطناعي" description="أداء محرك OCR/AI، معدلات التحويل للمختصين، وجودة الاستخراج" />
      <div className="mb-6">
        <ScaffoldNotice feature="مقاييس استخدام AI (عدد المحادثات، نسبة التحويل، زمن الاستجابة)، تتطلب تسجيل تحليلي إضافي في الـ Backend" />
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {MOCK_METRICS.map((m) => (
          <Card key={m.label}>
            <CardContent className="flex items-center gap-4 p-5">
              <div className="rounded-xl bg-primary/10 p-3"><m.icon className="h-5 w-5 text-primary" /></div>
              <div>
                <p className="text-xs text-muted-foreground">{m.label}</p>
                <p className="font-display text-xl font-bold">{m.value}</p>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card className="mt-6">
        <CardContent className="p-6 text-sm leading-relaxed text-muted-foreground">
          <p className="mb-2 font-semibold text-foreground">ما هو متصل فعليًا اليوم:</p>
          <p>
            محرك السلامة الدوائي (التكرار/التعارض/الحساسية) يعمل بقواعد محددة (deterministic) ويُختبر تلقائيًا في
            الـ Backend. ما يحتاج بناءً إضافيًا هو طبقة "تحليلات استخدام الذكاء الاصطناعي" (تسجيل كل استدعاء AI
            مع الزمن ومعدل التصعيد) لتتغذى منها هذه الشاشة ببيانات حقيقية.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
