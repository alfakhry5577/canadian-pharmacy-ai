import { AuthLayout } from "@/layouts/AuthLayout";
import { RegisterForm } from "@/features/auth/RegisterForm";

export default function RegisterPage() {
  return (
    <AuthLayout title="إنشاء حساب جديد" subtitle="انضم إلى روشتة AI كزبون أو صيدلاني">
      <RegisterForm />
    </AuthLayout>
  );
}
