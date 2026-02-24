# Keep Flutter and generated plugin classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Retrofit/Gson model signatures used in Dio responses
-keepattributes Signature
-keepattributes *Annotation*

# Keep Kotlin coroutines metadata
-keep class kotlin.Metadata { *; }
