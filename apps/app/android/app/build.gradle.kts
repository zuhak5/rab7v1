plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rideiq.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.rideiq.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appAuthRedirectScheme"] = "com.rideiq.app"
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.rideiq.app.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "RideIQ Dev")
            manifestPlaceholders["appAuthRedirectScheme"] = "com.rideiq.app.dev"
        }
        create("prod") {
            dimension = "env"
            applicationId = "com.rideiq.app"
            resValue("string", "app_name", "RideIQ")
            manifestPlaceholders["appAuthRedirectScheme"] = "com.rideiq.app"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
