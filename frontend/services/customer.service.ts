import { apiClient } from "@/lib/axios";
import type { LoyaltyAccount, Reminder, ReminderCreatePayload } from "@/types";

export const customerService = {
  listReminders: async (): Promise<Reminder[]> => {
    const { data } = await apiClient.get<Reminder[]>("/api/customer/reminders");
    return data;
  },

  createReminder: async (payload: ReminderCreatePayload): Promise<Reminder> => {
    const { data } = await apiClient.post<Reminder>("/api/customer/reminders", payload);
    return data;
  },

  cancelReminder: async (id: number): Promise<void> => {
    await apiClient.delete(`/api/customer/reminders/${id}`);
  },

  loyalty: async (): Promise<LoyaltyAccount> => {
    const { data } = await apiClient.get<LoyaltyAccount>("/api/customer/loyalty");
    return data;
  },
};
