# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.**

# Gson/Moshi-style reflection used transitively by some plugins
-keepattributes Signature
-keepattributes *Annotation*

# flutter_local_notifications
-keep class com.dexterous.** { *; }
