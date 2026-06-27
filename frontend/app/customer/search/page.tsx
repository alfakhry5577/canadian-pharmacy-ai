"use client";

import { useState } from "react";
import { PageHeader, EmptyState } from "@/components/shared/PageHeader";
import { SearchBar } from "@/features/search/SearchBar";
import { MedicationResultCard } from "@/features/search/MedicationResultCard";
import { useMedicationSearch } from "@/hooks/useMedicationSearch";
import { Skeleton } from "@/components/ui/skeleton";
import { Search as SearchIcon } from "lucide-react";

export default function CustomerSearchPage() {
  const [query, setQuery] = useState("");
  const { results, isLoading, hasQuery } = useMedicationSearch(query);

  return (
    <div>
      <PageHeader title="البحث عن دواء" description="ابحث بالاسم العربي أو الإنجليزي، أو بالمادة الفعالة" />
      <div className="mb-6 max-w-xl"><SearchBar value={query} onChange={setQuery} /></div>

      {!hasQuery && (
        <EmptyState icon={SearchIcon} title="ابدأ بكتابة اسم الدواء" description="مثال: بنادول، أو Ibuprofen" />
      )}

      {isLoading && (
        <div className="grid gap-4 sm:grid-cols-2">{Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-40 w-full rounded-2xl" />)}</div>
      )}

      {hasQuery && !isLoading && results.length === 0 && (
        <EmptyState icon={SearchIcon} title="لم يتم العثور على نتائج" description="جرّب كتابة الاسم بطريقة أخرى" />
      )}

      <div className="grid gap-4 sm:grid-cols-2">
        {results.map((r) => <MedicationResultCard key={r.medication.id} result={r} />)}
      </div>
    </div>
  );
}
