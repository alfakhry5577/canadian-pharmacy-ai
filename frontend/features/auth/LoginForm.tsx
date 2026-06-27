"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import { extractErrorMessage } from "@/lib/axios";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Callout } from "@/components/ui/callout";
import { ROUTES } from "@/lib/constants";

const schema = z.object({
  email: z.string().email("بريد إلكتروني غير صالح"),
  password: z.string().min(1, "أدخل كلمة المرور"),
});
type FormValues = z.infer<typeof schema>;

export function LoginForm() {
  const { login, isLoggingIn, loginError } = useAuth();
  const { register, handleSubmit, formState: { errors } } = useForm<FormValues>({ resolver: zodResolver(schema) });

  const onSubmit = (values: FormValues) => login(values).catch(() => undefined);

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
      {loginError && <Callout variant="critical">{extractErrorMessage(loginError)}</Callout>}

      <div>
        <Label htmlFor="email">البريد الإلكتروني</Label>
        <Input id="email" type="email" placeholder="name@example.com" {...register("email")} />
        {errors.email && <p className="mt-1 text-xs text-destructive">{errors.email.message}</p>}
      </div>

      <div>
        <Label htmlFor="password">كلمة المرور</Label>
        <Input id="password" type="password" placeholder="••••••••" {...register("password")} />
        {errors.password && <p className="mt-1 text-xs text-destructive">{errors.password.message}</p>}
      </div>

      <Button type="submit" className="w-full" isLoading={isLoggingIn}>
        تسجيل الدخول
      </Button>

      <p className="text-center text-sm text-muted-foreground">
        لا تملك حسابًا؟{" "}
        <Link href={ROUTES.register} className="font-semibold text-primary hover:underline">
          إنشاء حساب جديد
        </Link>
      </p>
    </form>
  );
}
