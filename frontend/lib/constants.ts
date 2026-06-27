export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

export const ROLE_LABELS_AR: Record<string, string> = {
  admin: "مدير النظام",
  pharmacist: "صيدلاني",
  customer: "زبون",
};

export const ROUTES = {
  home: "/",
  login: "/login",
  register: "/register",
  customer: {
    dashboard: "/customer/dashboard",
    search: "/customer/search",
    prescriptions: "/customer/prescriptions",
    prescriptionUpload: "/customer/prescriptions/upload",
    prescriptionDetail: (id: number | string) => `/customer/prescriptions/${id}`,
    reminders: "/customer/reminders",
    loyalty: "/customer/loyalty",
    chat: "/customer/chat",
  },
  pharmacist: {
    dashboard: "/pharmacist/dashboard",
    queue: "/pharmacist/queue",
    queueDetail: (id: number | string) => `/pharmacist/queue/${id}`,
    inventory: "/pharmacist/inventory",
    alerts: "/pharmacist/alerts",
    chat: "/pharmacist/chat",
  },
  admin: {
    dashboard: "/admin/dashboard",
    users: "/admin/users",
    inventory: "/admin/inventory",
    reports: "/admin/reports",
    aiMonitoring: "/admin/ai-monitoring",
    auditLogs: "/admin/audit-logs",
    settings: "/admin/settings",
  },
} as const;

/** Centralized React Query key factory — keeps cache invalidation consistent across hooks. */
export const queryKeys = {
  me: ["me"] as const,
  medicationSearch: (q: string) => ["medications", "search", q] as const,
  prescriptionsMine: ["prescriptions", "mine"] as const,
  prescriptionDetail: (id: number) => ["prescriptions", "detail", id] as const,
  prescriptionQueue: ["prescriptions", "queue"] as const,
  inventory: ["inventory"] as const,
  inventoryLowStock: ["inventory", "low-stock"] as const,
  alerts: (resolved: boolean) => ["alerts", resolved] as const,
  salesSummary: (days: number) => ["reports", "sales-summary", days] as const,
  reminders: ["customer", "reminders"] as const,
  loyalty: ["customer", "loyalty"] as const,
  chatHistory: (sessionId: number) => ["chat", "history", sessionId] as const,
};

export const SAFETY_SEVERITY_LABEL_AR: Record<string, string> = {
  info: "معلومة",
  warning: "تحذير",
  critical: "حرج",
};

export const PRESCRIPTION_STATUS_LABEL_AR: Record<string, string> = {
  pending: "قيد المعالجة",
  analyzed: "بانتظار مراجعة الصيدلاني",
  reviewed: "تمت المراجعة",
  dispensed: "تم الصرف",
  rejected: "مرفوضة",
};
