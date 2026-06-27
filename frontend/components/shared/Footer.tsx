export function Footer() {
  return (
    <footer className="border-t border-border bg-card">
      <div className="container grid gap-8 py-12 md:grid-cols-3">
        <div>
          <p className="mb-2 font-display text-lg font-bold text-primary">روشتة AI</p>
          <p className="text-sm leading-relaxed text-muted-foreground">
            مساعد ذكي للصيدليات يقرأ الوصفات الطبية ويسهّل البحث عن الأدوية، دون أن يحل محل الطبيب أو الصيدلاني.
          </p>
        </div>
        <div>
          <p className="mb-3 text-sm font-semibold">روابط سريعة</p>
          <ul className="space-y-2 text-sm text-muted-foreground">
            <li><a href="#features" className="hover:text-foreground">المميزات</a></li>
            <li><a href="#how-it-works" className="hover:text-foreground">كيف يعمل النظام</a></li>
            <li><a href="#safety" className="hover:text-foreground">السلامة الطبية</a></li>
          </ul>
        </div>
        <div>
          <p className="mb-3 text-sm font-semibold">تنبيه مهم</p>
          <p className="text-sm leading-relaxed text-muted-foreground">
            جميع المعلومات داخل التطبيق ذات طابع عام وتوعوي. لا تعتمد عليها كتشخيص نهائي أو بديل لمراجعة
            الطبيب أو الصيدلاني المرخّص، خصوصًا في الحالات العاجلة أو غير الواضحة.
          </p>
        </div>
      </div>
      <div className="border-t border-border py-4 text-center text-xs text-muted-foreground">
        © {new Date().getFullYear()} روشتة AI — جميع الحقوق محفوظة
      </div>
    </footer>
  );
}
