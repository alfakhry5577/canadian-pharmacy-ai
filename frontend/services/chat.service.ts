import { apiClient } from "@/lib/axios";
import type { ChatMessage, ChatReply } from "@/types";

export const chatService = {
  send: async (message: string, sessionId?: number): Promise<ChatReply> => {
    const { data } = await apiClient.post<ChatReply>("/api/chat/send", {
      message,
      session_id: sessionId,
    });
    return data;
  },

  history: async (sessionId: number): Promise<ChatMessage[]> => {
    const { data } = await apiClient.get<ChatMessage[]>(`/api/chat/${sessionId}/history`);
    return data;
  },
};
