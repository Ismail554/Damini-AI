# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase & Google Play Services / Identity / Credential Manager
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.libraries.identity.** { *; }
-keep class androidx.credentials.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.libraries.identity.**
-dontwarn androidx.credentials.**

# Firebase Messaging (FCM)
-keep public class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# Local Notifications Plugin
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Desugaring & Java 8+ support
-dontwarn java.lang.invoke.**
-dontwarn java.lang.SafeVarargs
