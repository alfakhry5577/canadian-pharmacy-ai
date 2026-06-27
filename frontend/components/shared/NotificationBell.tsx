"use client";

import { useState } from "react";
import { Bell, MailOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useNotifications, useUnreadNotificationCount, useMarkNotificationRead } from "@/hooks/useNotifications";
import { formatDate, cn } from "@/lib/utils";

export function NotificationBell() {
  const [open, setOpen] = useState(false);
  const { data: notifications } = useNotifications();
  const { data: unreadCount } = useUnreadNotificationCount();
  const markRead = useMarkNotificationRead();

  return (
    <div className="relative">
      <Button variant="ghost" size="icon" onClick={() => setOpen((o) => !o)} aria-label="الإشعارات">
        <Bell className="h-4 w-4" />
        {!!unreadCount && unreadCount > 0 && (
          <span className="absolute -end-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-destructive text-[10px] font-bold text-destructive-foreground">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
      </Button>

      {open && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setOpen(false)} />
          <div className="absolute end-0 top-full z-50 mt-2 w-80 rounded-xl border border-border bg-card p-2 shadow-lg">
            <p className="px-2 py-1.5 text-xs font-semibold text-muted-foreground">الإشعارات</p>
            <div className="max-h-80 overflow-y-auto">
              {!notifications || notifications.length === 0 ? (
                <p className="p-4 text-center text-sm text-muted-foreground">لا توجد إشعارات</p>
              ) : (
                notifications.map((n) => (
                  <button
                    key={n.id}
                    onClick={() => markRead.mutate(n.id)}
                    className={cn(
                      "flex w-full items-start gap-2 rounded-lg p-2.5 text-start text-sm hover:bg-accent",
                      !n.is_read && "bg-primary/5"
                    )}
                  >
                    {!n.is_read && <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-primary" />}
                    <span className="flex-1">
                      <span className="block font-semibold">{n.subject}</span>
                      <span className="block text-xs text-muted-foreground">{n.body}</span>
                      <span className="block text-[11px] text-muted-foreground/70">{formatDate(n.created_at)}</span>
                    </span>
                    {n.is_read && <MailOpen className="mt-0.5 h-3.5 w-3.5 shrink-0 text-muted-foreground" />}
                  </button>
                ))
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
