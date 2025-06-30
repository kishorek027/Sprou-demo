plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Google services Gradle plugin
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle plugin
}

android {
    namespace = "com.kishore.sprou"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Modified here

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.kishore.sprou"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // Add the dependencies for Firebase products you want to use
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase libraries here as needed
    // Example: implementation("com.google.firebase:firebase-auth")
}
