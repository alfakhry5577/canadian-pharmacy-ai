"use client";

import { useUIStore } from "@/store/ui.store";
import { Toast, ToastClose, ToastDescription, ToastProvider, ToastTitle, ToastViewport } from "@/components/ui/toast";

const VARIANT_MAP = {
  default: "default",
  success: "success",
  warning: "warning",
  destructive: "destructive",
} as const;

export function Toaster() {
  const { toasts, dismissToast } = useUIStore();

  return (
    <ToastProvider swipeDirection="left">
      {toasts.map(({ id, title, description, variant }) => (
        <Toast key={id} variant={VARIANT_MAP[variant]} onOpenChange={(open) => !open && dismissToast(id)}>
          <div className="grid gap-1">
            <ToastTitle>{title}</ToastTitle>
            {description && <ToastDescription>{description}</ToastDescription>}
          </div>
          <ToastClose />
        </Toast>
      ))}
      <ToastViewport />
    </ToastProvider>
  );
}
