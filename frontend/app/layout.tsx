import type { Metadata } from "next";
import "@/styles/globals.css";
import { AppProviders } from "@/providers/AppProviders";

export const metadata: Metadata = {
  title: "روشتة AI — مساعد الصيدلية الذكي",
  description: "منصة ذكية تربط الزبون والصيدلاني: تحليل الوصفات الطبية بالذكاء الاصطناعي، بحث الأدوية، التنبيهات الدوائية، وإدارة المخزون.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl">
      <body className="font-body antialiased">
        <AppProviders>{children}</AppProviders>
      </body>
    </html>
  );
}
