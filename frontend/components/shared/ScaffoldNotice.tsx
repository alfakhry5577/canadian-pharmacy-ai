import { FlaskConical } from "lucide-react";
import { Callout } from "@/components/ui/callout";

export function ScaffoldNotice({ feature }: { feature: string }) {
  return (
    <Callout variant="warning" title={`واجهة جاهزة، بانتظار ربط الـ Backend: ${feature}`}>
      <span className="flex items-start gap-2">
        <FlaskConical className="mt-0.5 h-4 w-4 shrink-0" />
        البيانات المعروضة هنا توضيحية (mock) لشرح التصميم والتدفق فقط. لتفعيل هذه الشاشة فعليًا، يلزم إضافة
        endpoints مطابقة في الـ Backend (انظر قسم "الأعمال المستقبلية" في README).
      </span>
    </Callout>
  );
}
