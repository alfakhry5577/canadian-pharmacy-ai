"use client";

import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import { extractErrorMessage } from "@/lib/axios";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Callout } from "@/components/ui/callout";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ROUTES } from "@/lib/constants";

const schema = z.object({
  full_name: z.string().min(2, "أدخل الاسم الكامل"),
  email: z.string().email("بريد إلكتروني غير صالح"),
  phone: z.string().optional(),
  password: z.string().min(8, "كلمة المرور يجب أن تكون 8 أحرف على الأقل"),
  role: z.enum(["customer", "pharmacist", "admin"]),
});
type FormValues = z.infer<typeof schema>;

export function RegisterForm() {
  const { register: registerUser, isRegistering, registerError } = useAuth();
  const { register, handleSubmit, control, formState: { errors } } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { role: "customer" },
  });

  const onSubmit = (values: FormValues) => registerUser(values).catch(() => undefined);

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4" noValidate>
      {registerError && <Callout variant="critical">{extractErrorMessage(registerError)}</Callout>}

      <div>
        <Label htmlFor="full_name">الاسم الكامل</Label>
        <Input id="full_name" {...register("full_name")} />
        {errors.full_name && <p className="mt-1 text-xs text-destructive">{errors.full_name.message}</p>}
      </div>

      <div>
        <Label htmlFor="email">البريد الإلكتروني</Label>
        <Input id="email" type="email" {...register("email")} />
        {errors.email && <p className="mt-1 text-xs text-destructive">{errors.email.message}</p>}
      </div>

      <div>
        <Label htmlFor="phone">رقم الهاتف (اختياري)</Label>
        <Input id="phone" {...register("phone")} />
      </div>

      <div>
        <Label htmlFor="password">كلمة المرور</Label>
        <Input id="password" type="password" {...register("password")} />
        {errors.password && <p className="mt-1 text-xs text-destructive">{errors.password.message}</p>}
      </div>

      <div>
        <Label>نوع الحساب</Label>
        <Controller
          control={control}
          name="role"
          render={({ field }) => (
            <Select value={field.value} onValueChange={field.onChange}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="customer">زبون</SelectItem>
                <SelectItem value="pharmacist">صيدلاني</SelectItem>
                <SelectItem value="admin">مدير النظام</SelectItem>
              </SelectContent>
            </Select>
          )}
        />
        <p className="mt-1 text-xs text-muted-foreground">
          ملاحظة توضيحية: في بيئة إنتاج حقيقية، حسابات الصيدلاني/الأدمن تُنشأ من لوحة الإدارة لا بتسجيل ذاتي مفتوح.
        </p>
      </div>

      <Button type="submit" className="w-full" isLoading={isRegistering}>
        إنشاء الحساب
      </Button>

      <p className="text-center text-sm text-muted-foreground">
        تملك حسابًا؟{" "}
        <Link href={ROUTES.login} className="font-semibold text-primary hover:underline">
          تسجيل الدخول
        </Link>
      </p>
    </form>
  );
}
