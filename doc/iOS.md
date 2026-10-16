# iOS & iPadOS Instructions

Julius supports iOS and iPadOS (iOS 16.0 or later), including iPad fullscreen edge-to-edge menu scaling and landscape lock.

## Prerequisites

1. macOS with Xcode 15+ installed.
2. CMake installed (`brew install cmake`).
3. SDL2 and SDL2_mixer source releases:
   Download the source archives (e.g. `SDL2-2.32.x` and `SDL2_mixer-2.8.x`) and extract them into the `ext/SDL2/` directory:
   - `ext/SDL2/SDL2-<version>`
   - `ext/SDL2/SDL2_mixer-<version>`
   (CMake will automatically detect folders matching `SDL*` and `SDL2_mixer*`).

## Generating the Xcode Project

From the project root:

```bash
mkdir build_ios && cd build_ios
cmake .. -DTARGET_PLATFORM=ios -G Xcode
```

Open the generated `build_ios/julius.xcodeproj` in Xcode.

## Build and Run

### Running in the iOS / iPadOS Simulator
1. In Xcode, select the `julius` scheme from the scheme dropdown.
2. Select any iPad or iPhone Simulator destination (e.g. iPad Pro).
3. Click **Run** (Cmd + R).

### Running on a Physical Device
1. Connect your iPad or iPhone to your Mac.
2. Select the `julius` target in Xcode project settings.
3. Under the **Signing & Capabilities** tab:
   - Check **Automatically manage signing**.
   - Select your **Team** (personal Apple ID / Free Developer account works).
   - Set a unique **Bundle Identifier** (e.g. `com.yourname.julius`).
4. Select your physical device in the Run Destinations dropdown and click **Run**.

## Providing Caesar III Game Files

Julius requires the original Caesar III data files (patched to version 1.0.1.0). You can provide them in either of two ways:

### Method 1: Apple Files App / Finder File Sharing (Recommended)
Because document sharing is enabled (`UIFileSharingEnabled`), Julius exposes its `Documents` directory to the system:
1. Open the **Files** app on your iPad (or connect the device to your Mac and open Finder > Files).
2. Navigate to **On My iPad** > **Julius**.
3. Copy your Caesar III game files (or `C3` folder) directly there.

### Method 2: In-Game File Picker
1. AirDrop or download your Caesar III folder to your device.
2. Launch Julius. On first run, it will display a system folder picker dialog.
3. Select your Caesar 3 folder and choose **Open**. Julius will copy the necessary files into its Documents container.