plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.specialvipturkiye"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.2.12479018"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.specialvipturkiye"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 5  // <-- Bunu 1'den 2'ye çıkar
        versionName = "1.0.4"  // <-- Bunu da güncelle (örn: 1.0.1)
    }

    signingConfigs {
        create("release") {
            storeFile = file(project.property("MYAPP_KEYSTORE") as String)
            storePassword = project.property("MYAPP_STORE_PASSWORD") as String
            keyAlias = project.property("MYAPP_KEY_ALIAS") as String
            keyPassword = project.property("MYAPP_KEY_PASSWORD") as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

}

flutter {
    source = "../.."
}
dependencies {
    implementation("com.google.android.material:material:1.9.0")
}
