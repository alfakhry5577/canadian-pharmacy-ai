"use client";

import { useState } from "react";
import Link from "next/link";
import {
  ScanLine, Search, ShieldCheck, Bell, PackageSearch, MessageSquareText,
  Stethoscope, UploadCloud, CheckCircle2, ArrowLeft,
} from "lucide-react";
import { Navbar } from "@/components/shared/Navbar";
import { Footer } from "@/components/shared/Footer";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Callout } from "@/components/ui/callout";
import { SearchBar } from "@/features/search/SearchBar";
import { MedicationResultCard } from "@/features/search/MedicationResultCard";
import { useMedicationSearch } from "@/hooks/useMedicationSearch";
import { useAuthStore } from "@/store/auth.store";
import { ROUTES } from "@/lib/constants";

const FEATURES = [
  { icon: ScanLine, title: "قراءة الروشتة بالـ OCR والذكاء الاصطناعي", desc: "صوّر وصفتك، ودعنا نستخرج اسم الدواء والجرعة والتكرار والمدة تلقائيًا." },
  { icon: PackageSearch, title: "بحث ذكي عن الأدوية والبدائل", desc: "ابحث بالعربية أو الإنجليزية، واحصل فورًا على بدائل متوفرة عند نفاد المخزون." },
  { icon: ShieldCheck, title: "محرك سلامة دوائي", desc: "كشف تلقائي للتكرار، التعارض الدوائي، الحساسية، وتحذيرات الحمل والأطفال وكبار السن." },
  { icon: Bell, title: "تذكير بإعادة الشراء", desc: "لا تفوّت موعد دواء مزمن، مع تذكير تلقائي قبل النفاد." },
  { icon: MessageSquareText, title: "دردشة ذكية آمنة", desc: "اسأل عن استخدامات الأدوية والتحذيرات العامة، مع تحويل فوري للحالات الحرجة." },
  { icon: Stethoscope, title: "لوحة تحكم للصيدلاني", desc: "مراجعة سريعة لكل وصفة، مع تعديل وتأكيد البيانات المستخرجة قبل الصرف." },
];

const STEPS = [
  { icon: UploadCloud, title: "صوّر وصفتك", desc: "ارفع صورة الروشتة من جهازك مباشرة." },
  { icon: ScanLine, title: "تحليل بالذكاء الاصطناعي", desc: "استخراج الأدوية والجرعات وفحوصات السلامة تلقائيًا." },
  { icon: CheckCircle2, title: "مراجعة الصيدلاني واعتمادها", desc: "القرار النهائي دائمًا بيد الصيدلاني المرخّص." },
];

function HeroSearch() {
  const [query, setQuery] = useState("");
  const { results, isLoading, hasQuery } = useMedicationSearch(query);

  return (
    <div className="rounded-2xl border border-border bg-card p-4 shadow-sm">
      <SearchBar value={query} onChange={setQuery} />
      {hasQuery && (
        <div className="mt-4 max-h-72 space-y-3 overflow-y-auto">
          {isLoading && <p className="py-4 text-center text-sm text-muted-foreground">جاري البحث...</p>}
          {!isLoading && results.length === 0 && (
            <p className="py-4 text-center text-sm text-muted-foreground">لم يتم العثور على نتائج مطابقة.</p>
          )}
          {results.slice(0, 3).map((r) => <MedicationResultCard key={r.medication.id} result={r} />)}
        </div>
      )}
    </div>
  );
}

function PrescriptionScanIllustration() {
  return (
    <div className="relative rounded-2xl border border-border bg-card p-6 shadow-lg">
      <div className="absolute -end-3 -top-3 rounded-full bg-primary px-3 py-1 text-xs font-bold text-primary-foreground shadow-md">
        تحليل AI
      </div>
      <div className="space-y-3 rounded-xl border border-dashed border-border bg-muted/40 p-4">
        <div className="h-2.5 w-2/3 rounded-full bg-muted-foreground/30" />
        <div className="h-2.5 w-1/2 rounded-full bg-muted-foreground/20" />
        <div className="h-2.5 w-3/4 rounded-full bg-muted-foreground/30" />
        <div className="h-2.5 w-1/3 rounded-full bg-muted-foreground/20" />
      </div>
      <div className="my-3 flex items-center justify-center">
        <ScanLine className="h-6 w-6 animate-pulse text-primary" />
      </div>
      <div className="space-y-2">
        {[
          { label: "اسم الدواء", value: "بنادول 500 ملغ" },
          { label: "الجرعة", value: "قرص واحد" },
          { label: "عدد المرات", value: "3 مرات يوميًا" },
          { label: "المدة", value: "5 أيام" },
        ].map((row) => (
          <div key={row.label} className="flex items-center justify-between rounded-lg bg-primary/5 px-3 py-2 text-sm">
            <span className="text-muted-foreground">{row.label}</span>
            <span className="font-semibold">{row.value}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function HomePage() {
  const { token, user } = useAuthStore();
  const uploadHref = token && user ? ROUTES.customer.prescriptionUpload : ROUTES.login;

  return (
    <div>
      <Navbar />

      {/* Hero */}
      <section className="container grid items-center gap-10 py-16 lg:grid-cols-2 lg:py-24">
        <div>
          <p className="eyebrow mb-3 font-body text-sm font-semibold uppercase tracking-wide text-primary">
            مساعد الصيدلية الذكي
          </p>
          <h1 className="mb-5 font-display text-4xl font-bold leading-tight sm:text-5xl">
            صوّر وصفتك، ودع <span className="text-primary">روشتة AI</span> يساعدك ويساعد صيدلانيّك
          </h1>
          <p className="mb-8 max-w-md text-lg text-muted-foreground">
            بحث ذكي عن الأدوية، تحليل فوري للوصفات الطبية بالـ OCR والذكاء الاصطناعي، وتنبيهات سلامة دوائية —
            كل ذلك دون أن يحل محل قرار طبيبك أو صيدلانيك.
          </p>
          <div className="flex flex-wrap gap-3">
            <Button asChild size="lg">
              <Link href={uploadHref}><UploadCloud className="h-4 w-4" /> رفع وصفة طبية</Link>
            </Button>
            <Button asChild size="lg" variant="outline">
              <Link href={ROUTES.register}>إنشاء حساب صيدلية <ArrowLeft className="h-4 w-4" /></Link>
            </Button>
          </div>
        </div>
        <PrescriptionScanIllustration />
      </section>

      {/* Search */}
      <section className="container pb-16">
        <h2 className="mb-4 text-center font-display text-2xl font-bold">جرّب البحث عن دواء الآن</h2>
        <div className="mx-auto max-w-xl">
          <HeroSearch />
        </div>
      </section>

      {/* Features */}
      <section id="features" className="bg-card py-20">
        <div className="container">
          <h2 className="mb-2 text-center font-display text-3xl font-bold">كل ما تحتاجه صيدليتك في مكان واحد</h2>
          <p className="mb-12 text-center text-muted-foreground">للزبون والصيدلاني معًا</p>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {FEATURES.map((f) => (
              <Card key={f.title}>
                <CardContent className="p-6">
                  <div className="mb-4 inline-flex rounded-xl bg-primary/10 p-3"><f.icon className="h-6 w-6 text-primary" /></div>
                  <h3 className="mb-2 font-display text-lg font-bold">{f.title}</h3>
                  <p className="text-sm leading-relaxed text-muted-foreground">{f.desc}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* How it works */}
      <section id="how-it-works" className="py-20">
        <div className="container">
          <h2 className="mb-12 text-center font-display text-3xl font-bold">كيف يعمل النظام؟</h2>
          <div className="grid gap-8 sm:grid-cols-3">
            {STEPS.map((s, i) => (
              <div key={s.title} className="text-center">
                <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
                  <s.icon className="h-7 w-7 text-primary" />
                </div>
                <p className="mb-1 text-sm font-semibold text-primary">الخطوة {i + 1}</p>
                <h3 className="mb-2 font-display text-lg font-bold">{s.title}</h3>
                <p className="text-sm text-muted-foreground">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Safety */}
      <section id="safety" className="bg-accent py-20">
        <div className="container max-w-3xl">
          <h2 className="mb-6 text-center font-display text-3xl font-bold">السلامة الطبية أولًا</h2>
          <Callout variant="critical" title="هذا النظام أداة مساعدة، وليس بديلاً عن الطبيب أو الصيدلاني">
            لا يقدّم روشتة AI تشخيصًا طبيًا نهائيًا، ولا يحدد أو يغيّر أي جرعة علاجية، ولا يحل محل القرار المهني
            للطبيب أو الصيدلاني المرخّص. في أي حالة غامضة أو خطيرة، يُحوَّل المستخدم فورًا لمراجعة مختص أو الطوارئ.
          </Callout>
        </div>
      </section>

      <Footer />
    </div>
  );
}
