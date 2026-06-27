import os, re

ROOT = "/home/claude/pharmacy-ai-assistant/mobile"
def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read()

errors = []

main_dart = read("lib/main.dart")
app_dart = read("lib/app.dart")
firebase_options = read("lib/firebase_options.dart")
push_service = read("lib/core/notifications/push_notification_service.dart")
local_service = read("lib/core/notifications/local_notification_service.dart")

# 1. DefaultFirebaseOptions.currentPlatform must exist as referenced
if "DefaultFirebaseOptions.currentPlatform" in main_dart:
    if not re.search(r"static FirebaseOptions get currentPlatform", firebase_options):
        errors.append("[FIREBASE] main.dart uses DefaultFirebaseOptions.currentPlatform but firebase_options.dart has no such getter")

# 2. firebaseMessagingBackgroundHandler must be defined exactly where imported and used
if "FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)" in main_dart:
    if "import 'core/notifications/push_notification_service.dart';" not in main_dart:
        errors.append("[FIREBASE] main.dart calls firebaseMessagingBackgroundHandler without importing its source file")
    if not re.search(r"Future<void> firebaseMessagingBackgroundHandler\(RemoteMessage message\)", push_service):
        errors.append("[FIREBASE] firebaseMessagingBackgroundHandler signature not found in push_notification_service.dart")

# 3. PushNotificationService public API used in app.dart must exist
ps_methods_used = set(re.findall(r"_pushService!\.(\w+)", app_dart))
ps_methods_defined = set(re.findall(r"\b(?:Future<[^>]+>|Stream<[^>]+>|void)\s+(\w+)\s*\(", push_service))
missing_methods = {m for m in ps_methods_used if m not in ps_methods_defined and m not in push_service}
for m in missing_methods:
    errors.append(f"[FIREBASE] app.dart calls PushNotificationService.{m}() but no such member found")

# Specifically check 'init' and 'onTokenRefresh'
if "PushNotificationService(" in app_dart:
    ctor_m = re.search(r"class PushNotificationService \{\s*PushNotificationService\(\{([^}]*)\}\)", push_service)
    if not ctor_m:
        errors.append("[FIREBASE] PushNotificationService constructor signature not found/parseable")
    else:
        required_named = re.findall(r"required this\.(\w+)", ctor_m.group(1))
        for name in required_named:
            if f"{name}:" not in app_dart:
                errors.append(f"[FIREBASE] PushNotificationService requires named arg '{name}' but app.dart doesn't pass it")

if "Future<String?> init(" not in push_service:
    errors.append("[FIREBASE] PushNotificationService.init() signature mismatch (app.dart awaits a String? token)")
if "Stream<String> get onTokenRefresh" not in push_service:
    errors.append("[FIREBASE] PushNotificationService.onTokenRefresh getter missing")

# 4. PushNotificationType enum values used in app.dart switch must all exist
enum_values = set(re.findall(r"enum PushNotificationType \{([^}]*)\}", push_service)[0].split(","))
enum_values = {v.strip() for v in enum_values if v.strip()}
switch_cases = set(re.findall(r"PushNotificationType\.(\w+):", app_dart))
missing_cases = enum_values - switch_cases
extra_cases = switch_cases - enum_values
if missing_cases:
    errors.append(f"[FIREBASE] app.dart switch on PushNotificationType is missing case(s): {missing_cases}")
if extra_cases:
    errors.append(f"[FIREBASE] app.dart switch references non-existent PushNotificationType case(s): {extra_cases}")

# 5. LocalNotificationService.init signature matches push_service usage
if "LocalNotificationService.instance.init(" in push_service:
    if "Future<void> init({required void Function(String? payload) onTapped})" not in local_service:
        errors.append("[FIREBASE] LocalNotificationService.init signature mismatch with caller in push_notification_service.dart")

# 6. Android Gradle Firebase setup
build_gradle = read("android/app/build.gradle")
if "firebase-messaging-ktx" not in build_gradle:
    errors.append("[FIREBASE] android/app/build.gradle missing firebase-messaging-ktx dependency")
if "firebase-bom" not in build_gradle:
    errors.append("[FIREBASE] android/app/build.gradle missing Firebase BoM platform()")
if "if (file('google-services.json').exists())" not in build_gradle:
    errors.append("[FIREBASE] google-services plugin application is not conditional")

print("Firebase audit errors:", len(errors))
for e in errors:
    print(" -", e)
