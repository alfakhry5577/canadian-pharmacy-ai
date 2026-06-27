import os, re, json

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
LIB = os.path.join(ROOT, "lib")

def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read()

def find_call_args(content, call_name):
    """Depth-aware extraction of the argument list text for the first `call_name(...)` occurrence."""
    idx = content.find(call_name + "(")
    if idx == -1:
        return None
    start = idx + len(call_name) + 1
    depth = 1
    i = start
    while i < len(content) and depth > 0:
        if content[i] == "(":
            depth += 1
        elif content[i] == ")":
            depth -= 1
        i += 1
    return content[start:i-1]

def split_top_level_args(args_str):
    args, depth, current = [], 0, ""
    for ch in args_str:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            args.append(current.strip())
            current = ""
        else:
            current += ch
    if current.strip():
        args.append(current.strip())
    return args

errors = []
core_providers = read("lib/providers/core_providers.dart")
repo_dir = os.path.join(LIB, "data/repositories")

for fname in sorted(os.listdir(repo_dir)):
    content = open(os.path.join(repo_dir, fname), encoding="utf-8").read()
    cls_m = re.search(r"class (\w+) \{", content)
    if not cls_m:
        continue
    cls = cls_m.group(1)
    ctor_args_str = find_call_args(content, cls)
    expected = len(split_top_level_args(ctor_args_str)) if ctor_args_str and ctor_args_str.strip() else 0

    inst_args_str = find_call_args(core_providers, cls)
    if inst_args_str is None:
        errors.append(f"[REPO-NOT-WIRED] {cls} never instantiated in core_providers.dart")
        continue
    actual = len(split_top_level_args(inst_args_str)) if inst_args_str.strip() else 0

    status = "OK" if expected == actual else "MISMATCH"
    print(f"{status}: {cls} — constructor expects {expected} arg(s), wired with {actual} arg(s)")
    if expected != actual:
        errors.append(f"[REPO-ARITY-MISMATCH] {cls}: expects {expected}, got {actual}")

print("\nReal errors after fix:", len(errors))

print("\n--- Services wiring check ---")
service_dir = os.path.join(LIB, "data/services")
errors2 = []
for fname in sorted(os.listdir(service_dir)):
    content = open(os.path.join(service_dir, fname), encoding="utf-8").read()
    cls_m = re.search(r"class (\w+) \{", content)
    if not cls_m:
        continue
    cls = cls_m.group(1)
    ctor_args_str = find_call_args(content, cls)
    expected = len(split_top_level_args(ctor_args_str)) if ctor_args_str and ctor_args_str.strip() else 0
    inst_args_str = find_call_args(core_providers, cls)
    if inst_args_str is None:
        errors2.append(f"[SERVICE-NOT-WIRED] {cls} never instantiated in core_providers.dart")
        continue
    actual = len(split_top_level_args(inst_args_str)) if inst_args_str.strip() else 0
    status = "OK" if expected == actual else "MISMATCH"
    print(f"{status}: {cls} — expects {expected}, wired {actual}")
    if expected != actual:
        errors2.append(f"[SERVICE-ARITY-MISMATCH] {cls}: expects {expected}, got {actual}")

print("\nService wiring errors:", len(errors2))

# ---- Localization completeness: every key in app_localizations.dart abstract class
#      must have a matching `String get key =>` override in BOTH Ar and En subclasses ----
print("\n--- Localization override completeness ---")
base = read("lib/l10n/app_localizations.dart")
ar = read("lib/l10n/app_localizations_ar.dart")
en = read("lib/l10n/app_localizations_en.dart")
abstract_keys = set(re.findall(r"String get (\w+);", base))
ar_keys = set(re.findall(r"String get (\w+) =>", ar))
en_keys = set(re.findall(r"String get (\w+) =>", en))
print("Abstract getters:", len(abstract_keys))
print("Missing in AR override:", abstract_keys - ar_keys)
print("Missing in EN override:", abstract_keys - en_keys)
print("Extra in AR (not in abstract):", ar_keys - abstract_keys)
print("Extra in EN (not in abstract):", en_keys - abstract_keys)
