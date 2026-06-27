"use client";

import { useCallback, useRef, useState } from "react";
import { ImagePlus, UploadCloud, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

interface UploadDropzoneProps {
  onFileSelected: (file: File) => void;
  isUploading?: boolean;
}

export function UploadDropzone({ onFileSelected, isUploading }: UploadDropzoneProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [isDragging, setIsDragging] = useState(false);

  const handleFile = useCallback(
    (file: File | undefined) => {
      if (!file) return;
      setPreview(URL.createObjectURL(file));
      onFileSelected(file);
    },
    [onFileSelected]
  );

  return (
    <div
      onDragOver={(e) => { e.preventDefault(); setIsDragging(true); }}
      onDragLeave={() => setIsDragging(false)}
      onDrop={(e) => {
        e.preventDefault();
        setIsDragging(false);
        handleFile(e.dataTransfer.files?.[0]);
      }}
      className={cn(
        "flex flex-col items-center justify-center gap-4 rounded-2xl border-2 border-dashed p-10 text-center transition-colors",
        isDragging ? "border-primary bg-primary/5" : "border-border",
        isUploading && "pointer-events-none opacity-70"
      )}
    >
      {preview ? (
        <div className="relative">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={preview} alt="معاينة صورة الروشتة" className="max-h-64 rounded-xl border border-border object-contain" />
          <button
            type="button"
            onClick={() => setPreview(null)}
            className="absolute -top-2 -end-2 rounded-full bg-card p-1 shadow-md"
            aria-label="إزالة الصورة"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      ) : (
        <div className="rounded-full bg-primary/10 p-4">
          <UploadCloud className="h-7 w-7 text-primary" />
        </div>
      )}

      <div>
        <p className="font-semibold">اسحب صورة الروشتة هنا أو اضغط للاختيار</p>
        <p className="mt-1 text-sm text-muted-foreground">JPG أو PNG — يُفضّل صورة واضحة بإضاءة جيدة</p>
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        capture="environment"
        className="hidden"
        onChange={(e) => handleFile(e.target.files?.[0])}
      />
      <Button type="button" variant="outline" onClick={() => inputRef.current?.click()} isLoading={isUploading}>
        <ImagePlus className="h-4 w-4" />
        {preview ? "اختيار صورة أخرى" : "اختيار صورة"}
      </Button>
    </div>
  );
}
