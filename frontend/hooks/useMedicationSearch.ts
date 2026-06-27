"use client";

import { useEffect, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { medicationService } from "@/services/medication.service";
import { queryKeys } from "@/lib/constants";

/** Debounces a value — used so search doesn't fire an API call on every keystroke. */
function useDebouncedValue<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timer);
  }, [value, delayMs]);
  return debounced;
}

export function useMedicationSearch(query: string) {
  const debouncedQuery = useDebouncedValue(query.trim(), 350);

  const searchQuery = useQuery({
    queryKey: queryKeys.medicationSearch(debouncedQuery),
    queryFn: () => medicationService.search(debouncedQuery),
    enabled: debouncedQuery.length >= 2,
  });

  return {
    results: searchQuery.data ?? [],
    isLoading: searchQuery.isFetching,
    isError: searchQuery.isError,
    hasQuery: debouncedQuery.length >= 2,
  };
}
