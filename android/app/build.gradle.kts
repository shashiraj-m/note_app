plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // FlutterFire config
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin (must come last)
}

android {
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    namespace = "com.example.note_app"

       compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.note_app"
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
