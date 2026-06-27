import os, re, json

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
LIB = os.path.join(ROOT, "lib")
errors = []
warnings = []

def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read()

# ---- 1. Constructor arity check: repositories defined vs instantiated in core_providers.dart ----
core_providers = read("lib/providers/core_providers.dart")
repo_dir = os.path.join(LIB, "data/repositories")
for fname in os.listdir(repo_dir):
    content = open(os.path.join(repo_dir, fname), encoding="utf-8").read()
    cls_m = re.search(r"class (\w+) \{", content)
    if not cls_m:
        continue
    cls = cls_m.group(1)
    ctor_m = re.search(rf"{cls}\((this\.\w+(?:, this\.\w+)*)\)", content)
    expected_args = len(ctor_m.group(1).split(",")) if ctor_m else None
    inst_m = re.search(rf"{cls}\(([^)]*)\)", core_providers)
    if inst_m is None:
        errors.append(f"[REPO-NOT-WIRED] {cls} is defined but never instantiated in core_providers.dart")
        continue
    # count top-level commas (naive, but args here are simple ref.watch(...) calls without nested commas issues since each watch has one arg)
    args_str = inst_m.group(1)
    actual_args = len([a for a in re.split(r",(?![^(]*\))", args_str) if a.strip()]) if args_str.strip() else 0
    if expected_args is not None and expected_args != actual_args:
        errors.append(f"[REPO-ARITY-MISMATCH] {cls}: constructor expects {expected_args} args, instantiated with {actual_args} in core_providers.dart")

# ---- 2. Double-Scaffold check: admin content screens must NOT define their own Scaffold (AdminShell already provides one) ----
admin_dir = os.path.join(LIB, "screens/admin")
for fname in os.listdir(admin_dir):
    if fname == "admin_shell.dart":
        continue
    content = open(os.path.join(admin_dir, fname), encoding="utf-8").read()
    if re.search(r"\bScaffold\(", content):
        errors.append(f"[DOUBLE-SCAFFOLD] screens/admin/{fname} defines its own Scaffold but is rendered inside AdminShell which already provides one")

# ---- 3. Customer/Pharmacist shell children SHOULD have their own Scaffold (shells only provide bottom nav, not AppBar) ----
for portal, shell_children in [
    ("customer", ["dashboard_screen.dart", "search_screen.dart", "prescription_history_screen.dart", "chat_screen.dart"]),
    ("pharmacist", ["dashboard_screen.dart", "queue_screen.dart", "inventory_screen.dart", "alerts_screen.dart", "chat_screen.dart"]),
]:
    for fname in shell_children:
        path = os.path.join(LIB, f"screens/{portal}/{fname}")
        content = open(path, encoding="utf-8").read()
        if not re.search(r"\bScaffold\(", content):
            errors.append(f"[MISSING-SCAFFOLD] screens/{portal}/{fname} is a ShellRoute child of {portal.capitalize()}Shell (bottom-nav only) but defines no Scaffold of its own")

# ---- 4. Route prefix consistency for RBAC redirect logic ----
route_paths = read("lib/core/router/route_paths.dart")
app_router = read("lib/core/router/app_router.dart")
const_defs = dict(re.findall(r"static const (\w+) = '([^']+)';", route_paths))

for const_name, value in const_defs.items():
    if const_name.startswith("customer") and const_name != "customerRoot":
        if not value.startswith("/customer"):
            errors.append(f"[ROUTE-PREFIX-MISMATCH] RoutePaths.{const_name} = '{value}' does not start with /customer")
    if const_name.startswith("pharmacist") and const_name != "pharmacistRoot":
        if not value.startswith("/pharmacist"):
            errors.append(f"[ROUTE-PREFIX-MISMATCH] RoutePaths.{const_name} = '{value}' does not start with /pharmacist")
    if const_name.startswith("admin") and const_name != "adminRoot":
        if not value.startswith("/admin"):
            errors.append(f"[ROUTE-PREFIX-MISMATCH] RoutePaths.{const_name} = '{value}' does not start with /admin")

# ---- 5. Every route registered in app_router.dart's GoRoute(path: RoutePaths.X) must have X defined ----
used_consts = set(re.findall(r"RoutePaths\.(\w+)\b", app_router))
defined_consts_and_methods = set(const_defs.keys()) | set(re.findall(r"static String (\w+)\(", route_paths))
missing = used_consts - defined_consts_and_methods
for m in missing:
    errors.append(f"[ROUTE-PATHS-MEMBER-MISSING] app_router.dart uses RoutePaths.{m} which is not defined")

# ---- 6. Android namespace / applicationId / MainActivity package consistency ----
build_gradle = read("android/app/build.gradle")
ns_m = re.search(r"namespace ['\"]([\w.]+)['\"]", build_gradle)
app_id_m = re.search(r"applicationId ['\"]([\w.]+)['\"]", build_gradle)
main_activity_path = "android/app/src/main/kotlin/com/roshetta/pharmacy/MainActivity.kt"
main_activity = read(main_activity_path)
pkg_m = re.search(r"^package ([\w.]+)", main_activity, re.MULTILINE)

if ns_m and app_id_m and ns_m.group(1) != app_id_m.group(1):
    warnings.append(f"[NAMESPACE-VS-APPLICATIONID] namespace={ns_m.group(1)} differs from applicationId={app_id_m.group(1)} (allowed, but unusual)")
if pkg_m and ns_m and pkg_m.group(1) != ns_m.group(1):
    errors.append(f"[KOTLIN-PACKAGE-MISMATCH] MainActivity.kt package={pkg_m.group(1)} != Gradle namespace={ns_m.group(1)}")
expected_dir = "android/app/src/main/kotlin/" + ns_m.group(1).replace(".", "/") + "/MainActivity.kt" if ns_m else None
if expected_dir and not os.path.isfile(os.path.join(ROOT, expected_dir)):
    errors.append(f"[KOTLIN-FILE-PATH-MISMATCH] Expected MainActivity.kt at {expected_dir} based on namespace {ns_m.group(1)}")

# ---- 7. google-services plugin must be conditional (build must succeed without google-services.json) ----
if "apply plugin: 'com.google.gms.google-services'" in build_gradle and "if (file('google-services.json').exists())" not in build_gradle:
    errors.append("[GOOGLE-SERVICES-NOT-CONDITIONAL] google-services plugin is applied unconditionally — build will fail without a real google-services.json")

# ---- 8. settings.gradle plugin versions match build.gradle classpath versions (AGP/Kotlin) ----
settings_gradle = read("android/settings.gradle")
agp_settings = re.search(r'id "com\.android\.application" version "([\d.]+)"', settings_gradle)
agp_buildscript = re.search(r"com\.android\.tools\.build:gradle:([\d.]+)", read("android/build.gradle"))
if agp_settings and agp_buildscript and agp_settings.group(1) != agp_buildscript.group(1):
    errors.append(f"[AGP-VERSION-MISMATCH] settings.gradle declares AGP {agp_settings.group(1)} but android/build.gradle classpath uses {agp_buildscript.group(1)}")

print("Deep-check errors:", len(errors))
for e in errors:
    print(" -", e)
print("Deep-check warnings:", len(warnings))
for w in warnings:
    print(" -", w)

json.dump({"errors": errors, "warnings": warnings}, open("/home/claude/audit/deep_results.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
