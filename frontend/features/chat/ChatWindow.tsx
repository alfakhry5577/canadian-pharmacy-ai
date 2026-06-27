"use client";

import { useEffect, useRef, useState } from "react";
import { Send, ShieldAlert } from "lucide-react";
import { ChatBubble } from "@/features/chat/ChatBubble";
import { SuggestedQuestions } from "@/features/chat/SuggestedQuestions";
import { useChat, SUGGESTED_QUESTIONS_AR } from "@/hooks/useChat";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Callout } from "@/components/ui/callout";
import { Card, CardContent } from "@/components/ui/card";

export function ChatWindow() {
  const { messages, sendMessage, isSending, escalateToPharmacist } = useChat();
  const [draft, setDraft] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = (text: string) => {
    if (!text.trim() || isSending) return;
    sendMessage(text.trim());
    setDraft("");
  };

  return (
    <Card className="flex h-[calc(100vh-220px)] min-h-[480px] flex-col">
      <CardContent className="flex flex-1 flex-col gap-4 overflow-hidden p-4">
        <Callout variant="info" title="مساعد معلومات عامة، وليس بديلاً عن الطبيب أو الصيدلاني">
          لا يقدّم هذا المساعد تشخيصًا ولا يغيّر جرعات علاجية. في الحالات العاجلة أو غير الواضحة، يرجى التواصل
          فورًا مع الصيدلاني أو الطوارئ.
        </Callout>

        {escalateToPharmacist && (
          <Callout variant="critical" title="يُفضّل التواصل المباشر">
            <span className="flex items-center gap-2">
              <ShieldAlert className="h-4 w-4" /> بناءً على رسالتك، يُنصح بالتواصل فورًا مع الصيدلاني أو الطبيب أو الطوارئ.
            </span>
          </Callout>
        )}

        <div className="flex-1 space-y-4 overflow-y-auto pe-1">
          {messages.length === 0 ? (
            <div className="flex h-full flex-col items-center justify-center gap-4 text-center">
              <p className="text-sm text-muted-foreground">جرّب أحد الأسئلة الشائعة، أو اكتب سؤالك مباشرة</p>
              <SuggestedQuestions questions={SUGGESTED_QUESTIONS_AR} onPick={handleSend} />
            </div>
          ) : (
            messages.map((m, idx) => (
              <ChatBubble key={m.id} message={m} animate={idx === messages.length - 1} />
            ))
          )}
          <div ref={bottomRef} />
        </div>

        <form
          onSubmit={(e) => { e.preventDefault(); handleSend(draft); }}
          className="flex items-center gap-2 border-t border-border pt-3"
        >
          <Input
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            placeholder="اكتب سؤالك هنا..."
            disabled={isSending}
          />
          <Button type="submit" size="icon" isLoading={isSending} aria-label="إرسال">
            <Send className="h-4 w-4" />
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
