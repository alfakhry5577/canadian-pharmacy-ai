import { AuthLayout } from "@/layouts/AuthLayout";
import { LoginForm } from "@/features/auth/LoginForm";

export default function LoginPage() {
  return (
    <AuthLayout title="تسجيل الدخول" subtitle="أدخل بيانات حسابك للوصول إلى لوحتك">
      <LoginForm />
    </AuthLayout>
  );
}
