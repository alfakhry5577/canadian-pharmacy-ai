"use client";

import { useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { chatService } from "@/services/chat.service";
import type { ChatMessage } from "@/types";

let localIdCounter = -1; // negative ids = optimistic, not-yet-persisted local messages

export function useChat() {
  const [sessionId, setSessionId] = useState<number | undefined>(undefined);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [escalate, setEscalate] = useState(false);

  const sendMutation = useMutation({
    mutationFn: (message: string) => chatService.send(message, sessionId),
    onMutate: (message: string) => {
      const optimisticUserMsg: ChatMessage = {
        id: localIdCounter--,
        role: "user",
        content: message,
        created_at: new Date().toISOString(),
      };
      setMessages((prev) => [...prev, optimisticUserMsg]);
    },
    onSuccess: (data) => {
      setSessionId(data.session_id);
      setEscalate(data.escalate_to_pharmacist);
      setMessages((prev) => [...prev, data.reply]);
    },
  });

  return {
    messages,
    sendMessage: sendMutation.mutate,
    isSending: sendMutation.isPending,
    error: sendMutation.error,
    escalateToPharmacist: escalate,
    sessionId,
  };
}

/** Common starter prompts shown above an empty chat — kept strictly within general/informational territory. */
export const SUGGESTED_QUESTIONS_AR = [
  "ما الفرق بين بنادول وبروفين؟",
  "هل يمكنني أخذ دواء البرد مع أدويتي المزمنة؟",
  "كيف أعرف أن دوائي قارب على النفاد؟",
  "ما معنى ظهور علامة 'تعارض دوائي' في وصفتي؟",
];
