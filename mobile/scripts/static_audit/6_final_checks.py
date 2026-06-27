import os, re

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read()

errors = []

# 1. Asset paths referenced in pubspec.yaml actually exist
pubspec = read("pubspec.yaml")
for m in re.finditer(r"image_path:\s*\"([^\"]+)\"", pubspec):
    if not os.path.isfile(os.path.join(ROOT, m.group(1))):
        errors.append(f"[ASSET-MISSING] flutter_launcher_icons image_path not found: {m.group(1)}")
for m in re.finditer(r"adaptive_icon_foreground:\s*\"([^\"]+)\"", pubspec):
    if not os.path.isfile(os.path.join(ROOT, m.group(1))):
        errors.append(f"[ASSET-MISSING] adaptive_icon_foreground not found: {m.group(1)}")
for m in re.finditer(r"image(?:_dark)?:\s*assets/[^\s]+", pubspec):
    path = m.group(0).split(":", 1)[1].strip()
    if not os.path.isfile(os.path.join(ROOT, path)):
        errors.append(f"[ASSET-MISSING] flutter_native_splash image not found: {path}")
for m in re.finditer(r"^\s*- (assets/[^\s]+)", pubspec, re.MULTILINE):
    p = os.path.join(ROOT, m.group(1))
    if not (os.path.isdir(p) or os.path.isfile(p)):
        errors.append(f"[ASSET-DIR-MISSING] declared asset path not found: {m.group(1)}")

# 2. Notification channel id consistency: AndroidManifest meta-data vs Dart constant
manifest = read("android/app/src/main/AndroidManifest.xml")
local_notif = read("lib/core/notifications/local_notification_service.dart")
manifest_channel = re.search(r'default_notification_channel_id"\s*\n\s*android:value="([^"]+)"', manifest)
dart_channel = re.search(r"AndroidNotificationChannel\(\s*\n?\s*'([^']+)'", local_notif)
if manifest_channel and dart_channel and manifest_channel.group(1) != dart_channel.group(1):
    errors.append(f"[CHANNEL-ID-MISMATCH] AndroidManifest declares default channel '{manifest_channel.group(1)}' but Dart code uses '{dart_channel.group(1)}'")
elif not manifest_channel:
    errors.append("[CHANNEL-ID-MISSING] AndroidManifest has no default_notification_channel_id meta-data")
elif not dart_channel:
    errors.append("[CHANNEL-ID-MISSING] Could not find AndroidNotificationChannel('...') in local_notification_service.dart")

# 3. pubspec name matches package: imports used in test/
pubspec_name = re.search(r"^name:\s*(\w+)", pubspec).group(1)
test_file = read("test/unit_test.dart")
used_pkg = set(re.findall(r"package:(\w+)/", test_file))
if pubspec_name not in used_pkg:
    errors.append(f"[TEST-PACKAGE-NAME-MISMATCH] pubspec name is '{pubspec_name}' but test file imports a different package name: {used_pkg}")

# 4. applicationId / namespace must be valid (lowercase, dot-separated, no hyphens)
build_gradle = read("android/app/build.gradle")
app_id = re.search(r"applicationId \"([\w.]+)\"", build_gradle).group(1)
if not re.match(r"^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$", app_id):
    errors.append(f"[INVALID-APPLICATION-ID] '{app_id}' does not look like a valid Android applicationId")

# 5. minSdkVersion sane for all plugins used (informational cross-check against pubspec deps known minimums)
min_sdk = int(re.search(r"minSdkVersion (\d+)", build_gradle).group(1))
KNOWN_MIN_SDKS = {"firebase_messaging": 21, "flutter_local_notifications": 21, "image_picker": 21, "flutter_secure_storage": 18}
for pkg, required in KNOWN_MIN_SDKS.items():
    if min_sdk < required:
        errors.append(f"[MINSDK-TOO-LOW] minSdkVersion={min_sdk} but {pkg} requires >= {required}")

print("Final-pass errors:", len(errors))
for e in errors:
    print(" -", e)
