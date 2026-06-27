import { apiClient } from "@/lib/axios";

export interface AppNotification {
  id: number;
  subject: string;
  body: string;
  is_read: boolean;
  created_at: string;
}

export const notificationService = {
  mine: async (): Promise<AppNotification[]> => {
    const { data } = await apiClient.get<AppNotification[]>("/api/notifications/mine");
    return data;
  },
  unreadCount: async (): Promise<number> => {
    const { data } = await apiClient.get<{ count: number }>("/api/notifications/unread-count");
    return data.count;
  },
  markRead: async (id: number): Promise<AppNotification> => {
    const { data } = await apiClient.patch<AppNotification>(`/api/notifications/${id}/read`);
    return data;
  },
};
