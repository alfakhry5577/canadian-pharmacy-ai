"use client";

import { PageHeader } from "@/components/shared/PageHeader";
import { LoyaltyCard } from "@/features/loyalty/LoyaltyCard";
import { Skeleton } from "@/components/ui/skeleton";
import { useLoyalty } from "@/hooks/useReminders";

export default function LoyaltyPage() {
  const { data: account, isLoading } = useLoyalty();

  return (
    <div>
      <PageHeader title="نقاط الولاء" description="اجمع النقاط مع كل عملية شراء واستبدلها بخصومات" />
      <div className="max-w-md">
        {isLoading || !account ? <Skeleton className="h-64 w-full rounded-2xl" /> : <LoyaltyCard account={account} />}
      </div>
    </div>
  );
}
