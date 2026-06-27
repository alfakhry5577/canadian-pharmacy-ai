"use client";

import { useEffect, useState } from "react";
import { Bot, User } from "lucide-react";
import { cn } from "@/lib/utils";
import type { ChatMessage } from "@/types";

/**
 * The backend (`/api/chat/send`) returns one complete message per call — there is
 * no token-level SSE/WebSocket streaming yet (see README "Future Work"). This
 * typewriter reveal gives a streaming *feel* in the UI without faking data.
 */
function useTypewriter(text: string, enabled: boolean, speedMs = 12) {
  const [shown, setShown] = useState(enabled ? "" : text);

  useEffect(() => {
    if (!enabled) {
      setShown(text);
      return;
    }
    setShown("");
    let i = 0;
    const interval = setInterval(() => {
      i += 1;
      setShown(text.slice(0, i));
      if (i >= text.length) clearInterval(interval);
    }, speedMs);
    return () => clearInterval(interval);
  }, [text, enabled, speedMs]);

  return shown;
}

export function ChatBubble({ message, animate }: { message: ChatMessage; animate?: boolean }) {
  const isUser = message.role === "user";
  const displayedText = useTypewriter(message.content, !!animate && !isUser);

  return (
    <div className={cn("flex items-start gap-2.5", isUser && "flex-row-reverse")}>
      <div className={cn("flex h-8 w-8 shrink-0 items-center justify-center rounded-full", isUser ? "bg-primary/15" : "bg-secondary/15")}>
        {isUser ? <User className="h-4 w-4 text-primary" /> : <Bot className="h-4 w-4 text-secondary" />}
      </div>
      <div
        className={cn(
          "max-w-[80%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed",
          isUser ? "bg-primary text-primary-foreground" : "bg-muted text-foreground"
        )}
      >
        {displayedText}
      </div>
    </div>
  );
}
