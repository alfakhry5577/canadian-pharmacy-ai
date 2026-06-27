"use client";

import { useState } from "react";
import { PageHeader } from "@/components/shared/PageHeader";
import { ScaffoldNotice } from "@/components/shared/ScaffoldNotice";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";

export default function AdminSettingsPage() {
  const [pharmacyName, setPharmacyName] = useState("صيدلية روشتة AI");
  const [aiModel, setAiModel] = useState("claude-sonnet-4-6");

  return (
    <div>
      <PageHeader title="إعدادات النظام" description="إعدادات عامة عن الصيدلية ومحرك الذكاء الاصطناعي" />
      <div className="mb-6">
        <ScaffoldNotice feature="PATCH /api/admin/settings — الإعدادات حاليًا تُضبط من ملف .env في الـ Backend" />
      </div>

      <div className="max-w-2xl space-y-6">
        <Card>
          <CardHeader><CardTitle>معلومات الصيدلية</CardTitle></CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="pharmacyName">اسم الصيدلية</Label>
              <Input id="pharmacyName" value={pharmacyName} onChange={(e) => setPharmacyName(e.target.value)} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>إعدادات الذكاء الاصطناعي</CardTitle></CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label htmlFor="aiModel">النموذج المستخدم (AI_MODEL في .env)</Label>
              <Input id="aiModel" value={aiModel} onChange={(e) => setAiModel(e.target.value)} />
            </div>
            <Separator />
            <p className="text-xs leading-relaxed text-muted-foreground">
              تذكير أمان: مفتاح ANTHROPIC_API_KEY يُضبط فقط من متغيرات البيئة على الخادم، ولا يجب أبدًا عرضه أو
              إرساله إلى الواجهة الأمامية.
            </p>
          </CardContent>
        </Card>

        <Button disabled>حفظ التغييرات (بانتظار endpoint الإعدادات)</Button>
      </div>
    </div>
  );
}
