# Prevent stripping of TensorFlow Lite GPU Delegate
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**
