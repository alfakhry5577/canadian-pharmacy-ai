import { PageHeader } from "@/components/shared/PageHeader";
import { ScaffoldNotice } from "@/components/shared/ScaffoldNotice";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

const MOCK_LOGS = [
  { id: 1, actor: "pharmacist@roshetta.ai", action: "اعتماد وصفة #102", at: "2026-06-20 14:05" },
  { id: 2, actor: "admin@roshetta.ai", action: "تعديل حد إعادة الطلب لدواء #14", at: "2026-06-20 11:22" },
  { id: 3, actor: "pharmacist@roshetta.ai", action: "رفض وصفة #99 — صورة غير واضحة", at: "2026-06-19 19:47" },
];

export default function AdminAuditLogsPage() {
  return (
    <div>
      <PageHeader title="سجل التدقيق" description="سجل الإجراءات الحساسة: اعتماد/رفض الوصفات، تعديلات المخزون، تغييرات الصلاحيات" />
      <div className="mb-6">
        <ScaffoldNotice feature="جدول audit_logs + middleware لتسجيل كل إجراء حساس تلقائيًا" />
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>المستخدم</TableHead>
            <TableHead>الإجراء</TableHead>
            <TableHead>التاريخ والوقت</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {MOCK_LOGS.map((log) => (
            <TableRow key={log.id}>
              <TableCell><Badge variant="outline">{log.actor}</Badge></TableCell>
              <TableCell>{log.action}</TableCell>
              <TableCell className="font-mono text-xs text-muted-foreground">{log.at}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
