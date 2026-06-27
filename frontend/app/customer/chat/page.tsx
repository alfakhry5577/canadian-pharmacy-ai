import { PageHeader } from "@/components/shared/PageHeader";
import { ChatWindow } from "@/features/chat/ChatWindow";

export default function CustomerChatPage() {
  return (
    <div>
      <PageHeader title="المساعد الذكي" description="معلومات عامة عن الأدوية — وليس تشخيصًا أو بديلاً عن الصيدلاني" />
      <ChatWindow />
    </div>
  );
}
