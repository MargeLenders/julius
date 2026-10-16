# 🏛️ Julius — Native iPadOS & iOS Port of Caesar III

[![Platform](https://img.shields.io/badge/Platform-iPadOS%2016%2B%20%7C%20iOS%2016%2B%20%7C%20macOS-blue.svg)](https://developer.apple.com)
[![Architecture](https://img.shields.io/badge/Architecture-ARM64%20(Apple%20Silicon)-orange.svg)](https://www.apple.com)
[![License](https://img.shields.io/badge/License-AGPL--3.0-purple.svg)](LICENSE.txt)
[![Fork of](https://img.shields.io/badge/Fork%20of-bvschaik%2Fjulius-brightgreen.svg)](https://github.com/bvschaik/julius)
[![Language: Español](https://img.shields.io/badge/Language-Español-yellow.svg)](README.es.md)

> 🏛️ **This repository is an enhanced fork of [bvschaik/julius](https://github.com/bvschaik/julius)** bringing native iPadOS support, edge-to-edge UI & menu scaling, full-screen landscape locking, modern `UIWindowScene` lifecycle, and native Apple Files app document sharing to Caesar III.
>
> 📖 *Leer en [Español](README.es.md)*

Julius is an open-source re-implementation of the classic city-builder **Caesar III (Impressions Games, 1998)**. This fork allows you to compile and install Julius natively on your **iPad or iPhone** using modern Xcode and a free Apple ID, with full touch control, edge-to-edge menu presentation, and zero emulation overhead.

---

## ✨ Key Features in this iPadOS Fork

* **📺 Modern `UIWindowScene` Lifecycle (iOS 16+)**:
  * Seamless integration with Apple's modern scene delegate architecture, eliminating black-screen startup bugs.
  * Native fullscreen landscape orientation locking (`LandscapeLeft` / `LandscapeRight`).
* **📐 Edge-to-Edge UI & Background Scaling**:
  * Title screen, mission briefing dialogs, intermezzos, and career selection screens dynamically scale to fill modern iPad display ratios edge-to-edge without letterboxing or distortion.
* **📁 Direct Game File Management via Apple Files App**:
  * `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` enabled out-of-the-box.
  * Transfer your original Caesar 3 files directly into `On My iPad > Julius` using the native **Files** app or Mac **Finder** file sharing—no third-party file transfer tools required.
* **🎮 Touch Controls & Peripherals**:
  * 1:1 touch interaction for constructing roads, aqueducts, and zoning.
  * Two-finger scrolling for smooth map navigation.
  * Full support for **Apple Pencil**, **Magic Keyboard**, Bluetooth mice, and trackpads.
* **💾 100% Save Game Compatibility**:
  * Save files are 100% compatible with the original Caesar III and desktop Julius releases.
  * Saves are stored directly in your accessible Documents directory for easy backup and export.
* **⚡ Clean Modern Toolchain Builds**:
  * Compiler, libtool (`-no_warning_for_no_symbols`), and linker alignment (`-fno-common`) warnings resolved for Xcode 15/16+ and Apple Clang.

---

## 🏛️ Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│             iPadOS Host Layer (UIKit)                  │
│   • UIWindowSceneDelegate & orientation locking        │
│   • Apple Files app sandbox sharing (UIFileSharing)    │
│   • Native Multitouch & Apple Pencil input routing     │
└──────────────────────────┬─────────────────────────────┘
                           │ SDL2 SysWM / UIKit backend
                           ▼
┌────────────────────────────────────────────────────────┐
│            SDL2 & SDL2_mixer Multimedia Layer          │
│   • Static ARM64 Metal / OpenGLES video presentation   │
│   • Low-latency CoreAudio output engine                │
│   • Screen scaling & dynamic viewport sizing           │
└──────────────────────────┬─────────────────────────────┘
                           │ Native C Engine calls
                           ▼
┌────────────────────────────────────────────────────────┐
│             Julius Core Game Engine (AGPL-3.0)         │
│   • Vanilla Caesar III simulation & game logic         │
│   • Asset loading from ~/Documents/C3/ or ~/Documents/ │
│   • Byte-compatible save/load engine                   │
└────────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

1. **Mac (Apple Silicon or Intel)**:
   * macOS 14 (Sonoma) or macOS 15 (Sequoia) or later.
   * **Xcode 15 or later** installed from the Mac App Store.
   * Xcode Command Line Tools installed (`xcode-select --install`).
   * **Homebrew** installed ([brew.sh](https://brew.sh)).
2. **iPad (or iPhone)**:
   * Running **iPadOS 16.0 or later**.
   * USB-C or Lightning cable to connect to your Mac.
3. **Free Apple ID Account**:
   * A standard free personal Apple ID works fine—no paid $99/year developer membership required.
4. **Original Caesar III Data Files**:
   * A legitimate digital copy from [GOG.com](https://www.gog.com/game/caesar_3) (version 1.0.1.0).

---

## 🚀 Step-by-Step Tutorial: From GOG to Your iPad

Follow these steps to extract your game files, build the project, and install Caesar III on your iPad:

### Step 1: Install Build Tools on Your Mac

Open **Terminal** on your Mac and install `cmake` and `innoextract` using Homebrew:

```bash
brew install cmake innoextract
```

---

### Step 2: Download and Extract Caesar III from GOG

1. Log into your [GOG.com](https://www.gog.com) account, navigate to your library, select **Caesar 3**, and under **Download Offline Backup Game Installers**, download the installer executable (e.g. `setup_caesar_3_1.0.1.0_(...).exe`).
2. In Terminal, extract the files from the GOG installer:
   ```bash
   cd ~/Downloads
   innoextract setup_caesar_3*.exe -d c3_extracted
   ```
3. Prepare the game data folder named **`C3`** on your Desktop:
   ```bash
   mv c3_extracted/app ~/Desktop/C3
   ```
   *(If the files are located directly in the root of `c3_extracted`, simply move the whole folder: `mv c3_extracted ~/Desktop/C3`).*

---

### Step 3: Clone this Repository

```bash
git clone https://github.com/MargeLenders/julius.git
cd julius
```

---

### Step 4: Download SDL2 and SDL2_mixer Dependencies

Download the required SDL2 source packages directly into `ext/SDL2/`:

```bash
mkdir -p ext/SDL2
curl -L https://github.com/libsdl-org/SDL/releases/download/release-2.32.8/SDL2-2.32.8.tar.gz | tar xz -C ext/SDL2
curl -L https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.1/SDL2_mixer-2.8.1.tar.gz | tar xz -C ext/SDL2
```

---

### Step 5: Generate the Xcode Project

Generate the iOS/iPadOS Xcode project using CMake:

```bash
mkdir build_ios && cd build_ios
cmake .. -DTARGET_PLATFORM=ios -G Xcode
open julius.xcodeproj
```

---

### Step 6: Configure Code Signing in Xcode

1. In the left Xcode navigator, click the top blue **julius** project icon.
2. Under **TARGETS**, select **julius**.
3. Select the **Signing & Capabilities** tab.
4. Check **Automatically manage signing**.
5. In the **Team** dropdown, select your personal team (*Personal Team*). If prompted, click *Add Account...* and log in with your free Apple ID.
6. In **Bundle Identifier**, replace `com.github.bvschaik.julius` with your own unique identifier:
   ```text
   com.yourname.julius
   ```

```
┌────────────────────────────────────────────────────────────────────────┐
│ Signing & Capabilities                                                │
├────────────────────────────────────────────────────────────────────────┤
│ [✓] Automatically manage signing                                      │
│                                                                        │
│ Team:              [ Your Name (Personal Team)               ▼ ]      │
│ Bundle Identifier: [ com.yourname.julius                             ] │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Step 7: Enable Developer Mode on Your iPad (First Time Only)

On your iPad running iPadOS 16+:
1. Open **Settings** $\rightarrow$ **Privacy & Security**.
2. Scroll to the bottom and tap **Developer Mode**.
3. Toggle it to **On** and tap **Restart**.
4. After restarting, unlock your device and tap **Turn On**, then enter your iPad passcode.

---

### Step 8: Build and Install on Your iPad

1. Connect your iPad to your Mac via USB cable (tap **Trust This Computer** on your iPad if prompted).
2. In the top toolbar of Xcode, select **julius** as the scheme and choose **your physical iPad** as the destination.
3. Click the **Run (▶)** button or press `Cmd + R`.
4. Xcode will compile Julius, link SDL2, and install the app on your device.

---

### Step 9: Trust the Developer Certificate on iPad

If you see an *"Untrusted Developer"* warning when opening Julius for the first time:
1. On your iPad, open **Settings** $\rightarrow$ **General**.
2. Tap **VPN & Device Management**.
3. Under *Developer App*, tap your **Apple ID** and select **Trust**.

---

### Step 10: Copy Your `C3` Game Files to the iPad

Because document sharing is enabled, copying your files takes seconds:

#### Option A: Via Mac Finder (Recommended)
1. In macOS **Finder**, select your connected **iPad** in the sidebar.
2. Click the **Files** tab at the top.
3. Locate the **julius** folder in the list.
4. Drag and drop your **`C3`** folder from `~/Desktop/C3` directly onto the **julius** icon.

#### Option B: Via the iPad Files App (AirDrop / iCloud)
1. Send your **`C3`** folder to your iPad via AirDrop or place it in iCloud Drive.
2. Open the **Files** app on your iPad.
3. Move the **`C3`** folder into **On My iPad** $\rightarrow$ **julius**.

---

### Step 11: Launch and Enjoy Caesar III! 🍇

Tap **Julius** on your iPad home screen. The game will automatically detect your `C3` folder, initialize the sound engine, and boot into full-screen Caesar III.

---

## 🎮 iPad Controls & Gestures

| Gesture / Input | Action in Caesar III | Description |
| :--- | :--- | :--- |
| **1-Finger Tap** | **Left Click** | Select buildings, place roads/aqueducts, interact with UI buttons. |
| **1-Finger Drag** | **Drag / Construct** | Drag to construct roads, walls, aqueducts, and clear land. |
| **2-Finger Pan / Drag** | **Scroll Map** | Smoothly pan the city view across the map. |
| **2-Finger Tap or Long Press** | **Right Click** | Inspect houses, query citizens, or cancel construction mode. |
| **Apple Pencil** | **Precision Pointer** | Pixel-accurate placement of infrastructure and tiny buttons. |
| **Magic Keyboard** | **Hotkeys** | Use `P` to pause, `Space` for overlays, numbers `1`–`5` for game speed. |
| **Bluetooth Mouse / Trackpad** | **Desktop Mouse** | Native cursor control with left and right click. |

---

## ❓ FAQ & Troubleshooting

#### Q: How long does the app stay active on a free Apple ID?
**A:** Apple's free personal certificates last **7 days**. When the certificate expires, **do not delete the app** (deleting the app would erase your save games). Simply connect your iPad back to your Mac, open Xcode, and press **Run (▶)** (`Cmd + R`). The certificate will refresh for another 7 days with all your saves intact.

#### Q: Where are save games stored?
**A:** Saves are stored in the `C3` directory inside `On My iPad > Julius`. You can copy, back up, or transfer them to a desktop PC anytime via the iPad Files app or Mac Finder.

#### Q: Xcode shows *"Failed to register bundle identifier"*.
**A:** Bundle identifiers must be globally unique across all Apple developers. Change `com.yourname.julius` to another identifier in **Signing & Capabilities** (e.g. `com.yournickname.caesar3`).

#### Q: Can I change display scaling or zoom?
**A:** Yes! In-game, open **Options** $\rightarrow$ **Display Settings** to adjust the viewport scaling percentage to your liking.

---

## ℹ️ About the Original Julius Project

* **Upstream Repository:** [bvschaik/julius](https://github.com/bvschaik/julius)
* **Lead Developer:** Bianca van Schaik ([@bvschaik](https://github.com/bvschaik))
* **Official Julius Wiki:** [bvschaik/julius/wiki](https://github.com/bvschaik/julius/wiki)
* **Community Chat:** [Discord](http://www.discord.gg/GamerZakh)

---

## ⚖️ Legal Disclaimer & License

* **Caesar III**: © 1998 Sierra On-Line, Inc. / Activision. All rights reserved. Neither this repository nor its contributors distribute copyrighted game assets, data files, sounds, or music. You must supply your own legitimate copy of Caesar III.
* **Julius**: Released under the **GNU Affero General Public License v3.0 (AGPL-3.0)**. See [LICENSE.txt](LICENSE.txt) for details.
