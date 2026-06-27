# FINAL_BUILD_READINESS_REPORT.md — Roshetta AI Mobile

Scope: pure production-build readiness for `flutter pub get`, `flutter analyze`, `flutter test`,
`flutter build apk --release`, `flutter build appbundle --release`. No new features. One dependency fix
applied below (justified, real, confirmed-pattern risk) — everything else is reporting only.

---

## 1) Build Blockers (must be zero) → **0 confirmed**

None found that I can verify with certainty using static inspection. One **fixed** before it could become one:

| # | Issue | Confidence | Status |
|---|---|---|---|
| 1 | `pubspec.yaml` pinned `intl: ^0.19.0`. `flutter_localizations` (an SDK package) pins its own exact/narrow `intl` requirement tied to whichever Flutter SDK version is installed. A narrow caret range here is the single most common real-world cause of `flutter pub get` version-solving failure in Flutter projects that use localization. | High (well-documented recurring failure pattern) | **Fixed** → changed to `intl: any`, letting `flutter_localizations`' own constraint drive resolution. |

No other blocker met the bar of "confirmed" — everything else below is a risk I can describe precisely but
cannot verify without an actual `flutter pub get` / Dart compiler / Gradle run, which this sandbox cannot
perform (no network path to Flutter/Dart SDK or Maven/Google's package hosts — same limitation documented in
the prior audit).

---

## 2) High-Risk Issues

| # | Issue | Why it matters | Mitigation already in place |
|---|---|---|---|
| 1 | **`pub get` transitive version resolution is unverified.** 26 direct dependencies are pinned with caret ranges I chose from memory of typical compatible versions; I cannot run pub's solver to confirm there is no conflict in the dependency *graph* (e.g. two packages both depending on incompatible `collection` or `meta` versions). | This is the #1 realistic reason `flutter pub get` could fail outright. | None beyond reasonable version selection — **this can only be fully confirmed by actually running `flutter pub get`**, which CI will do first. |
| 2 | **`CardThemeData` usage in `core/theme/app_theme.dart`** (2 occurrences: light + dark theme). Flutter renamed several legacy `XTheme` classes to `XThemeData` (e.g. `CardTheme`→`CardThemeData`) at some point in its release history. I do not have certain knowledge of the exact Flutter version where this became required vs. merely available, and CI installs whatever is "stable" *on the day the workflow runs* — a moving target I cannot pin down from here. | If the installed stable SDK predates this rename, `CardThemeData` won't exist → compile error in exactly 2 lines. If it postdates the rename far enough that the *old* name was hard-removed, that's not a risk for us either way since we already use the new name. | Not changed — deliberately left alone per your instruction not to speculatively edit code without a confirmed blocker. If CI fails here, the fix is a one-line revert to `CardTheme(...)` in both occurrences. |

---

## 3) Medium-Risk Issues

| # | Issue | Detail |
|---|---|---|
| 1 | **`Color.withOpacity(...)` used pervasively** (~40+ call sites across theme/widgets/screens). Flutter deprecated this in favor of `Color.withValues(alpha: ...)`. As of my training data, this was a *deprecation* (still compiles, analyzer hint only), not a removal. Flutter's stated deprecation policy keeps deprecated APIs for a minimum period before hard removal, so outright removal by the time this CI runs is possible but not confirmed. | If it is still deprecated-but-functional: zero impact on the build, at most analyzer info-level hints (already excluded from failing the build by `--no-fatal-warnings`/default analyze behavior for infos). If it has been hard-removed: ~40+ compile errors, all mechanically fixable by a find/replace `withOpacity(x)` → `withValues(alpha: x)`. |
| 2 | **`channel: "stable"` in `mobile-build.yml` is a floating target.** Every CI run installs whichever Flutter version is "stable" *that day*, not a version I tested against. This is the root cause of risks #2 (High) and #1 (Medium) above — the workflow is reproducible day-to-day but not pinned to a known-good version. | Trade-off: pinning to a specific version avoids drift risk but requires me to guess an exact version string I cannot verify exists. Left as `stable` deliberately rather than risk specifying a non-existent version tag, which would be a guaranteed failure instead of a possible one. |
| 3 | **Firebase is genuinely unconfigured** (`lib/firebase_options.dart` is a documented placeholder; no `android/app/google-services.json` is present). | Does **not** block `flutter build apk`/`appbundle` — `main.dart` wraps `Firebase.initializeApp()` in try/catch and continues without it. It does mean push notifications are inert until configured (by design, documented). |
| 4 | **No real release keystore present** (`android/key.properties` does not exist; only `key.properties.example`). | `flutter build apk --release` / `appbundle --release` will **still succeed** — `app/build.gradle`'s signing config falls back to the debug key when `key.properties` is absent. The output is installable/testable but not Play-Store-eligible until a real keystore + CI secrets are added (already documented in `mobile/README.md`). |

---

## 4) Low-Risk Issues

| # | Issue | Detail |
|---|---|---|
| 1 | `compileSdk`/`targetSdk` = 34 (Android 14). Google Play's *minimum target API for new submissions* is raised roughly once a year; by the time of an actual Play Store upload, 34 may be below the then-current requirement. | Irrelevant to `flutter build` succeeding today. Relevant only at Play Console upload time — bump `compileSdk`/`targetSdk` in `android/app/build.gradle` if Play Console rejects the AAB for targeting an old API level. |
| 2 | `package_info_plus` is declared in `pubspec.yaml` but not currently imported anywhere in `lib/`. | Harmless (unused dependency, not unused import) — does not affect build success, only adds a small amount of unused transitive footprint. |
| 3 | `flutter analyze --no-fatal-warnings` in the workflow assumes that flag name is correct for the CI-installed Flutter version's CLI. | If the flag name is wrong, that specific CI *step* fails with a CLI usage error (not a Dart compile error) — would surface immediately and unambiguously in the Action log, and is a one-line workflow fix. Does not affect `flutter build apk`/`appbundle`, which run as separate steps regardless. |

---

## 5) Missing Files → **None**

Every file referenced by code, Gradle, or config was confirmed present in this session's re-inspection:
99 Dart files, both AndroidManifest variants, MainActivity.kt at the namespace-correct path, all 3 generated
localization files (`app_localizations.dart/_ar.dart/_en.dart`), all Gradle files, ProGuard rules, and
`key.properties.example`/`local.properties.example` (intentionally examples, not the real gitignored files —
expected and documented).

## 6) Missing Assets → **None**

`assets/images/app_icon.png`, `app_icon_foreground.png`, and `splash_logo.png` are real, non-placeholder PNGs
(verified present, non-zero size, referenced correctly by `flutter_launcher_icons`/`flutter_native_splash`
config in `pubspec.yaml`).

## 7) Missing Firebase Requirements

- `android/app/google-services.json` — **not present** (expected; CI restores it from
  `secrets.ANDROID_GOOGLE_SERVICES_JSON_BASE64` if set, otherwise build proceeds without it).
- `lib/firebase_options.dart` — present but **placeholder values**; run `flutterfire configure` against a real
  Firebase project to replace it.
- Backend endpoint `POST /api/notifications/device-token` — **does not exist yet** on the FastAPI backend;
  the mobile app calls it defensively (silently ignores 404). Documented in `mobile/README.md`.

None of the above block `flutter build apk`/`appbundle`.

## 8) Required Environment Variables

| Variable | Where | Required for build? | Default if absent |
|---|---|---|---|
| `API_BASE_URL` | `--dart-define` at build time | No | `https://api.roshetta.ai` (workflow) / `http://10.0.2.2:8000` (pubspec-level default in `api_endpoints.dart` for local `flutter run`) |
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | GitHub Actions secrets | No (falls back to debug signing) | Debug signing |
| `ANDROID_GOOGLE_SERVICES_JSON_BASE64` | GitHub Actions secret | No | Firebase stays uninitialized at runtime |

No environment variable is required for `flutter build apk`/`appbundle` to **succeed** — all of the above only
change *what* gets built (signing, API target, push capability), not *whether* it builds.

## 9) Required Android SDK Version

- `compileSdkVersion`: **34**
- `targetSdkVersion`: **34**
- `minSdkVersion`: **23**
- Build-Tools/Platform 34 must be installed on whatever machine/runner executes the Gradle build (GitHub
  Actions' Flutter/Android images include this; a fresh local machine needs `sdkmanager "platforms;android-34"`).

## 10) Required Flutter Version

- `pubspec.yaml` declares `flutter: ">=3.22.0"` as a **floor**, not a tested exact version.
- The CI workflow installs `channel: stable` (whatever is current on the day it runs).
- I cannot state a single exact "required" version with certainty from this sandbox (see High-Risk #2). Practical
  recommendation: if you want a fully deterministic, repeatable build, pin `subosito/flutter-action@v2` to a
  specific `flutter-version: 'x.y.z'` you have personally verified `flutter pub get && flutter build apk` against
  once — then this entire High-Risk item disappears.

## 11) Required Java Version

- **Java 17** (Temurin), explicitly set in:
  - `android/app/build.gradle` → `sourceCompatibility`/`targetCompatibility`/`kotlinOptions.jvmTarget`
  - `.github/workflows/mobile-build.yml` → `actions/setup-java@v4` with `java-version: "17"`
- Required because AGP 8.3.2 mandates JDK 17+ for Gradle execution.

---

## Final Answers

### If `flutter build apk` is executed today, what is the estimated success probability?

**≈ 88–93%.**

This is slightly more conservative than the previous audit's 90–95% estimate, specifically because this pass
surfaced and fixed one real, high-confidence dependency-resolution risk (`intl`) that hadn't been examined
before — finding a real issue is a signal that others of the same *class* (pub version resolution across all
26 dependencies, not just `intl`) remain statistically possible even though none were individually identified.
The number did not move to "lower" because of new code (no new code was added besides the one fix and screens
remain structurally validated from the prior audit) — it moved to reflect honest calibration given what was
just learned.

### What are the top 5 reasons the build could fail?

1. **`flutter pub get` version-solving conflict** among the 26 pinned dependencies (the one identified instance
   — `intl` vs. `flutter_localizations` — is fixed; an unidentified instance elsewhere is the single most
   likely remaining failure mode).
2. **`CardThemeData` not recognized** by whichever exact Flutter stable version CI installs (High-Risk #2)
   — 2-line fix if it happens.
3. **AGP/Gradle/Kotlin/Java toolchain mismatch** surfacing only at actual Gradle execution time (versions were
   cross-checked for known compatibility, but never executed).
4. **A genuine Dart type error** too subtle for structural/regex-based static audit to catch (e.g., a method
   returning a slightly wrong generic type) — actively searched for and none found, but a real compiler is the
   only fully authoritative check.
5. **`flutter analyze --no-fatal-warnings` flag rejected** by the installed Flutter CLI version (Low-Risk #3)
   — would fail the *analyze* CI step specifically, not the APK/AAB build steps, which run independently.

### What exact steps are required after receiving this project to generate a production APK?

1. `cd mobile && flutter pub get` — first real signal; resolves dependency graph for real.
2. `flutter analyze` — confirms zero structural/type errors beyond what static audit could check.
3. `flutter test` — runs the existing unit tests (`test/unit_test.dart`).
4. Generate a real release keystore and create `android/key.properties` from `key.properties.example`
   (skip this step only if a debug-signed test build is acceptable).
5. (Optional, for push notifications) `flutterfire configure --project=<your-firebase-project-id>` to replace
   the placeholder `lib/firebase_options.dart` and drop in a real `google-services.json`.
6. `flutter build appbundle --release --dart-define=API_BASE_URL=<your real backend URL>` for Play Store, and/or
   `flutter build apk --release --dart-define=API_BASE_URL=<your real backend URL>` for direct install/testing.
7. If step 1 or 2 fails: fix the specific error reported (most likely a version bump per Sections 2–3 above),
   then re-run from step 1.
