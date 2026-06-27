"use client";

import { useState } from "react";
import { Search, ShieldCheck, UserCog } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { ScaffoldNotice } from "@/components/shared/ScaffoldNotice";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { ROLE_LABELS_AR } from "@/lib/constants";

const MOCK_USERS = [
  { id: 1, full_name: "مدير النظام", email: "admin@roshetta.ai", role: "admin", is_active: true },
  { id: 2, full_name: "د. سارة الصيدلانية", email: "pharmacist@roshetta.ai", role: "pharmacist", is_active: true },
  { id: 3, full_name: "أحمد الزبون", email: "customer@roshetta.ai", role: "customer", is_active: true },
  { id: 4, full_name: "ليلى محمود", email: "layla@example.com", role: "customer", is_active: false },
];

export default function AdminUsersPage() {
  const [query, setQuery] = useState("");
  const filtered = MOCK_USERS.filter((u) => u.full_name.includes(query) || u.email.includes(query));

  return (
    <div>
      <PageHeader title="إدارة المستخدمين" description="عرض وإدارة حسابات الزبائن، الصيادلة، والمدراء" />
      <div className="mb-4"><ScaffoldNotice feature="GET/PATCH /api/admin/users (قائمة وتعديل المستخدمين)" /></div>

      <div className="mb-4 flex items-center gap-3">
        <div className="relative max-w-xs flex-1">
          <Search className="absolute inset-y-0 start-3 my-auto h-4 w-4 text-muted-foreground" />
          <Input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="ابحث بالاسم أو البريد..." className="ps-10" />
        </div>
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>الاسم</TableHead>
            <TableHead>البريد الإلكتروني</TableHead>
            <TableHead>الدور</TableHead>
            <TableHead>الحالة</TableHead>
            <TableHead>إجراء</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {filtered.map((u) => (
            <TableRow key={u.id}>
              <TableCell className="font-medium">{u.full_name}</TableCell>
              <TableCell className="text-muted-foreground">{u.email}</TableCell>
              <TableCell><Badge variant="outline"><ShieldCheck className="h-3 w-3" /> {ROLE_LABELS_AR[u.role]}</Badge></TableCell>
              <TableCell>{u.is_active ? <Badge variant="success">فعّال</Badge> : <Badge variant="muted">معطّل</Badge>}</TableCell>
              <TableCell><Button size="sm" variant="ghost" disabled><UserCog className="h-3.5 w-3.5" /> تعديل</Button></TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
