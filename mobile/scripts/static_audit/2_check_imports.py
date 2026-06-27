import os, re, json

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
LIB = os.path.join(ROOT, "lib")

records = json.load(open("/home/claude/audit/records.json", encoding="utf-8"))

errors = []
warnings = []

# ---- pubspec dependencies ----
pubspec_text = open(os.path.join(ROOT, "pubspec.yaml"), encoding="utf-8").read()
# crude YAML dependency name extraction (top-level keys under dependencies/dev_dependencies blocks)
def extract_deps(block_name):
    lines = pubspec_text.splitlines()
    names = set()
    in_block = False
    for line in lines:
        if re.match(rf"^{block_name}:\s*$", line):
            in_block = True
            continue
        if in_block:
            if line.strip() == "" or line.strip().startswith("#"):
                continue
            if re.match(r"^\S", line):  # new top-level key -> block ended
                break
            mm = re.match(r"^  (\w[\w_]*):", line)
            if mm:
                names.add(mm.group(1))
    return names

deps = extract_deps("dependencies") | extract_deps("dev_dependencies")
print("Declared pubspec dependencies:", sorted(deps))

SDK_PACKAGES = {"flutter", "flutter_test", "flutter_localizations", "flutter_driver", "test"}
OWN_PACKAGE = "roshetta_ai"

# ---- 1. Relative import resolution ----
for rel, data in records.items():
    file_dir = os.path.dirname(data["path"])
    for imp in data["imports"]:
        target = imp["target"]
        if target.startswith("package:"):
            pkg_name = target.split(":")[1].split("/")[0]
            if pkg_name == OWN_PACKAGE:
                # package:roshetta_ai/... should resolve relative to lib/
                sub_path = target.split("/", 1)[1] if "/" in target else ""
                resolved = os.path.join(LIB, sub_path)
                if not os.path.isfile(resolved):
                    errors.append(f"[OWN-PACKAGE-IMPORT-MISSING] {rel}: '{target}' -> no file at lib/{sub_path}")
            elif pkg_name in SDK_PACKAGES:
                pass  # provided by Flutter SDK, not pubspec.yaml
            elif pkg_name in deps:
                pass  # OK, declared
            else:
                errors.append(f"[UNDECLARED-PACKAGE] {rel}: imports 'package:{pkg_name}/...' which is NOT in pubspec.yaml dependencies")
        elif target.startswith("dart:"):
            pass  # Dart core SDK library
        else:
            # relative import
            resolved = os.path.normpath(os.path.join(file_dir, target))
            if not os.path.isfile(resolved):
                errors.append(f"[RELATIVE-IMPORT-MISSING] {rel}: '{target}' -> resolved to {os.path.relpath(resolved, ROOT)} which does not exist")

# ---- 2. Aliased import class-usage resolution ----
alias_targets = {}  # rel_file -> {alias: target_rel_path}
for rel, data in records.items():
    file_dir = os.path.dirname(data["path"])
    for imp in data["imports"]:
        if imp["alias"]:
            target = imp["target"]
            if target.startswith("package:") or target.startswith("dart:"):
                continue
            resolved = os.path.normpath(os.path.join(file_dir, target))
            resolved_rel = os.path.relpath(resolved, ROOT)
            alias_targets.setdefault(rel, {})[imp["alias"]] = resolved_rel

for rel, aliases in alias_targets.items():
    content = open(records[rel]["path"], encoding="utf-8").read()
    for alias, target_rel in aliases.items():
        # find alias.Identifier usages
        usages = set(re.findall(rf"\b{re.escape(alias)}\.(\w+)", content))
        target_classes = set(records.get(target_rel, {}).get("classes", []))
        for used_class in usages:
            if used_class not in target_classes:
                errors.append(f"[ALIASED-CLASS-MISSING] {rel}: uses '{alias}.{used_class}' but '{used_class}' is not a class defined in {target_rel} (classes there: {sorted(target_classes)})")

# ---- 3. Riverpod provider cross-check (definition vs usage) ----
all_providers_defined = set()
for rel, data in records.items():
    all_providers_defined.update(data["providers"])

provider_usage_pattern = re.compile(r"\b(ref\.(?:watch|read|listen)\(\s*)([a-zA-Z_]\w*Provider)\b")
for rel, data in records.items():
    content = open(data["path"], encoding="utf-8").read()
    for m in provider_usage_pattern.finditer(content):
        name = m.group(2)
        if name not in all_providers_defined:
            errors.append(f"[UNDEFINED-PROVIDER] {rel}: references '{name}' via ref.watch/read/listen, but no `final {name} = ...` definition found anywhere")

# ---- 4. Duplicate top-level class names across different files ----
class_owner = {}
for rel, data in records.items():
    for c in data["classes"]:
        class_owner.setdefault(c, []).append(rel)
for c, owners in class_owner.items():
    if len(owners) > 1:
        warnings.append(f"[DUPLICATE-CLASS-NAME] '{c}' is defined in multiple files: {owners} (OK only if always accessed via distinct aliases)")

# ---- 5. GoRouter route path consistency ----
route_paths_file = [rel for rel in records if rel.endswith("core/router/route_paths.dart")][0]
route_paths_content = open(records[route_paths_file]["path"], encoding="utf-8").read()
defined_route_constants = dict(re.findall(r"static\s+const\s+(\w+)\s*=\s*'([^']+)'", route_paths_content))
defined_route_methods = re.findall(r"static\s+String\s+(\w+)\(", route_paths_content)

app_router_file = [rel for rel in records if rel.endswith("core/router/app_router.dart")][0]
app_router_content = open(records[app_router_file]["path"], encoding="utf-8").read()

# Every GoRoute(path: ...) should be either a RoutePaths.xxx constant or a literal pattern like '/x/:id'
goroute_paths = re.findall(r"GoRoute\(\s*path:\s*([^,]+),", app_router_content)
for p in goroute_paths:
    p = p.strip()
    if p.startswith("RoutePaths."):
        const_name = p.split(".")[1]
        if const_name not in defined_route_constants:
            errors.append(f"[ROUTE-CONST-MISSING] app_router.dart references RoutePaths.{const_name} but it's not defined in route_paths.dart")
    elif p.startswith("'"):
        pass  # literal path pattern e.g. '/customer/prescriptions/:id' -- fine
    else:
        warnings.append(f"[ROUTE-PATH-UNRECOGNIZED-FORM] GoRoute path expression: {p}")

print(f"\nTotal errors: {len(errors)}")
for e in errors:
    print(" -", e)
print(f"\nTotal warnings: {len(warnings)}")
for w in warnings:
    print(" -", w)

json.dump({"errors": errors, "warnings": warnings}, open("/home/claude/audit/results.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
