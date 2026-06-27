import os, re, json

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
records = json.load(open("/home/claude/audit/records.json", encoding="utf-8"))

suspects = []
for rel, data in records.items():
    content = open(data["path"], encoding="utf-8").read()
    # strip the import lines themselves before searching for usage
    body = re.sub(r"^\s*import\s+['\"][^'\"]+['\"].*?;\s*$", "", content, flags=re.MULTILINE)

    for imp in data["imports"]:
        target = imp["target"]
        if imp["alias"]:
            # aliased usage already validated separately; just check the alias prefix appears
            if not re.search(rf"\b{re.escape(imp['alias'])}\.", body):
                suspects.append(f"{rel}: alias '{imp['alias']}' for '{target}' is never used as `{imp['alias']}.X`")
            continue
        if target.startswith("dart:") or target.startswith("package:flutter") or target.startswith("package:flutter_test"):
            continue  # too noisy / often used for side effects or types not captured by our crude regex
        if target.startswith("package:"):
            pkg = target.split(":")[1].split("/")[0]
            target_rel = None
        else:
            file_dir = os.path.dirname(data["path"])
            target_rel = os.path.relpath(os.path.normpath(os.path.join(file_dir, target)), ROOT)

        if target_rel and target_rel in records:
            exported = set(records[target_rel]["classes"]) | set(records[target_rel]["enums"]) | set(records[target_rel]["providers"]) | set(records[target_rel]["typedefs"])
            if exported and not any(re.search(rf"\b{re.escape(name)}\b", body) for name in exported):
                suspects.append(f"{rel}: imports '{target}' but none of its exported symbols {sorted(exported)[:5]}... appear used")

print(f"Potential unused-import suspects: {len(suspects)}")
for s in suspects:
    print(" -", s)
