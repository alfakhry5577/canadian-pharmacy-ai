import { PageHeader } from "@/components/shared/PageHeader";
import { ChatWindow } from "@/features/chat/ChatWindow";

export default function PharmacistChatPage() {
  return (
    <div>
      <PageHeader title="المساعد الذكي" description="مرجع سريع للجرعات العامة، البدائل، والتداخلات الدوائية الشائعة" />
      <ChatWindow />
    </div>
  );
}
