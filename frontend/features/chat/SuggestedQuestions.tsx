import { Sparkles } from "lucide-react";

export function SuggestedQuestions({ questions, onPick }: { questions: string[]; onPick: (q: string) => void }) {
  return (
    <div className="grid gap-2 sm:grid-cols-2">
      {questions.map((q) => (
        <button
          key={q}
          onClick={() => onPick(q)}
          className="flex items-start gap-2 rounded-xl border border-border bg-card p-3 text-start text-sm hover:border-primary hover:bg-primary/5"
        >
          <Sparkles className="mt-0.5 h-4 w-4 shrink-0 text-secondary" />
          {q}
        </button>
      ))}
    </div>
  );
}
