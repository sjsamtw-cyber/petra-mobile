import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties") // Assuming key.properties is in android/
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("Warning: key.properties not found in android/. Release builds may not be signed correctly.")
}

android {
    namespace = "com.petrasoftsolutions.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file("${keystoreProperties.getProperty("storeFile")}") // Assuming .jks is also in android/
                storePassword = keystoreProperties.getProperty("storePassword")
            } else {
                // Fallback or error if key.properties not found
                // For now, let's set placeholder values or leave them to cause a build error
                // to indicate that signing configuration is missing.
                // Or, you could configure it to use debug signing as a last resort,
                // but that's not suitable for actual releases.
                println("Release signing information not found in key.properties.")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // Enable desugaring
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.petrasoftsolutions.mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
// Strip integration_test registration from GeneratedPluginRegistrant for non-dev flavors
// This ensures CI/builds for QA/Staging/Prod won't fail if the dev-only plugin is present in the tracked/generated file.
// It runs before Java compilation for matching variant compile tasks.
tasks.register("stripIntegrationTestRegistration") {
    doLast {
        val genPath = "src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
        val genFile = file(genPath)
        if (!genFile.exists()) {
            println("stripIntegrationTestRegistration: $genPath not found, skipping")
            return@doLast
        }
        val content = genFile.readText()
        // Use a triple-quoted raw string and DOT_MATCHES_ALL to safely match the try/catch block across lines
        val pattern = Regex(
            """try\s*\{\s*flutterEngine\.getPlugins\(\)\.add\(new\s+dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\}\s*catch\s*\([^)]*\)\s*\{[^}]*\}""",
            RegexOption.DOT_MATCHES_ALL
        )
        if (pattern.containsMatchIn(content)) {
            val replacement = "    // integration_test plugin registration removed for non-dev builds"
            val newContent = content.replace(pattern, replacement)
            genFile.writeText(newContent)
            println("stripIntegrationTestRegistration: integration_test registration stripped from $genPath")
        } else {
            println("stripIntegrationTestRegistration: no integration_test registration found in $genPath")
        }
    }
}

// Run the strip task before Java compilation for QA, Staging, and Prod variants
val nonDevFlavorKeys = listOf("qa", "staging", "prod")
tasks.matching { it.name.matches(Regex("compile.*JavaWithJavac", RegexOption.IGNORE_CASE)) }.configureEach {
    val ln = this.name.lowercase()
    if (nonDevFlavorKeys.any { f -> ln.contains(f) }) {
        this.dependsOn("stripIntegrationTestRegistration")
    }
}
// ----- BEGIN flavorDimensions (autogenerated by flutter_flavorizr) -----
apply { from("flavorizr.gradle.kts") }
// ----- END flavorDimensions (autogenerated by flutter_flavorizr) -----