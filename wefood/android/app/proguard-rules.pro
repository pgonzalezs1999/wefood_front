# No modificar las clases de modelos JSON
-keepclassmembers class **.model.** { *; }

# No modificar clases que interactúan con el framework de Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# No optimices clases de bibliotecas que utilicen Reflection (muchas APIs como Firebase usan esto)
-keepattributes *Annotation*
-keep class ** { *; }
-dontwarn **

# No elimines clases usadas en login (si usas alguna librería de autenticación)
-keep class com.example.myapp.auth.** { *; }