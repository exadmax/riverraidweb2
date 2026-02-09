# Keep Flame game engine classes
-keep class io.flutter.** { *; }
-keep class com.flame.** { *; }

# Keep game classes
-keep class com.exadmax.riverraidweb2.** { *; }

# Optimization flags
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
