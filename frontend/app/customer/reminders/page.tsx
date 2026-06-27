import { PageHeader } from "@/components/shared/PageHeader";
import { ReminderList } from "@/features/reminders/ReminderList";

export default function RemindersPage() {
  return (
    <div>
      <PageHeader title="تذكيرات إعادة الشراء" description="لا تفوّت موعد دواء مزمن بعد الآن" />
      <ReminderList />
    </div>
  );
}
