import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { AlertTriangle, Info, ShieldAlert } from "lucide-react";
import { cn } from "@/lib/utils";

const calloutVariants = cva("flex items-start gap-3 rounded-xl border p-4 text-sm", {
  variants: {
    variant: {
      info: "border-blue-200 bg-blue-50 text-blue-900",
      warning: "border-amber-300 bg-amber-50 text-amber-900",
      critical: "border-destructive/30 bg-destructive/10 text-destructive",
    },
  },
  defaultVariants: { variant: "info" },
});

const ICONS = { info: Info, warning: AlertTriangle, critical: ShieldAlert };

export interface CalloutProps extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof calloutVariants> {
  title?: string;
}

function Callout({ className, variant = "info", title, children, ...props }: CalloutProps) {
  const Icon = ICONS[variant ?? "info"];
  return (
    <div className={cn(calloutVariants({ variant }), className)} {...props}>
      <Icon className="mt-0.5 h-5 w-5 shrink-0" />
      <div className="flex-1">
        {title && <p className="mb-1 font-semibold">{title}</p>}
        <div className="leading-relaxed">{children}</div>
      </div>
    </div>
  );
}

export { Callout };
