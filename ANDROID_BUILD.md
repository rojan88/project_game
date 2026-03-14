# Building Monster Pact for Android (M5.4)

## Prerequisites

1. **OpenJDK 17** — [Download](https://adoptium.net/temurin/releases/?variant=openjdk17)
2. **Android SDK** — Install via [Android Studio](https://developer.android.com/studio) (Iguana 2023.2.1 or later), or use the command-line tools.
   - Required: Platform-Tools 34+, Build-Tools 34, Platform 34, NDK r23c, CMake 3.10.2.4988404

## Godot editor setup

1. Open **Editor → Editor Settings** (or **Godot → Preferences** on macOS).
2. Go to **Export → Android**.
3. Set **Java SDK Path** to your OpenJDK 17 install (e.g. `/usr/lib/jvm/java-17-openjdk` or the path from Adoptium).
4. Set **Android SDK Path** (e.g. `C:\Users\<you>\AppData\Local\Android\Sdk` on Windows, `/Users/<you>/Library/Android/sdk` on macOS).

## Install Android build template

1. **Project → Install Android Build Template…** — Run this once so Godot can build APK/AAB.
2. Wait for the template to download and install.

## Add Android export preset

1. **Project → Export…**
2. Click **Add…** → choose **Android**. This creates `export_presets.cfg` with an Android preset.
3. Select the Android preset and set:
   - **Package name**: e.g. `com.yourstudio.monsterpact` (must be unique for Play Store)
   - **Version code**: 1 (integer; increment for each store upload)
   - **Version name**: e.g. `1.0.0`
   - **Export format**: **AAB** for Google Play, **APK** for direct install / testing
4. **Release (store) builds:** Create a keystore (e.g. `keytool -genkey -v -keystore release.keystore -alias mykey -keyalg RSA -keysize 2048 -validity 10000`). In the preset, set **Keystore/Release** path, alias, and passwords. Keep the keystore and password safe.
5. **Debug builds** can use the default debug keystore (no release keystore needed).

## Build

1. **Project → Export…** → select the **Android** preset.
2. Click **Export Project** and choose the output path (e.g. `monster_pact.apk` or `monster_pact.aab`).
3. Install the APK on a device or upload the AAB to Google Play Console.

## Store (Google Play)

- New apps must upload **Android App Bundle (AAB)**.
- Use a **release keystore** (not debug) and keep the keystore and password safe.
- Uncheck **Export With Debug** for store builds.
- See **STORE_ASSETS.md** for icon sizes, screenshots, and store listing text.
