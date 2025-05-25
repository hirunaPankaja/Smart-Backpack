import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Load .env properties
val localProperties = Properties()
val envFile = rootProject.file(".env")
if (envFile.exists()) {
    envFile.inputStream().use { localProperties.load(it) }
}
val googleMapsApiKey = localProperties["GOOGLE_MAPS_API_KEY"] as? String ?: ""

android {
    namespace = "com.example.smart_backpack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_backpack"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ Add the API key to your resources
        resValue("string", "GOOGLE_MAPS_API_KEY", googleMapsApiKey)
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
