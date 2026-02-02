# 🐰 Bunny Runner: Bulletproof Infinity Loop (Gold Release)

A professional, "zero-stress" automation system for **Bunny Runner 3D**, built with Lua for GameGuardian. This bot supports both **Root (Shell)** and **No-Root (Human Reset)** devices, featuring a "self-healing" state machine and intelligent pop-up navigation.

---

## ✨ Features (The Bulletproof Suite)

- **🤖 5-State Logic Engine**: Intelligently switches between `SCANNING`, `PLAYING`, `VICTORY`, `DEFEAT`, and `STUCK` states.
- **💓 12-Second Heartbeat**: Automatically detects game freezes or slow-loading ads and performing an **Emergency Reset**.
- **🧙 Intelligent Calibration Wizard**: Two-step automated setup that "learns" your App Icon position and Path DNA.
- **👻 The "Ghost Tap"**: Automatically navigates through daily rewards, news, and level-up pop-ups after app relaunch.
- **🖐️ Human Emulation (No-Root)**: Mimics human gestures (Swipe Recents -> Clear Card -> Relaunch) to bypass ads without root access.
- **🔍 Fuzzy Vision**: RGB-distance color matching that works under varying brightness and **Night Mode / Blue Light Filters**.

---

## 🛠️ Hybrid Architecture

### Root Mode (Ghost Reset)
Uses raw Android shell commands (`am force-stop`) for high-speed process kills and instant ad-bypassing.

### No-Root Mode (Human Reset)
Uses the Accessibility API to emulate human gestures, providing a 100% functional ad-avoidance strategy for standard Android devices.

---

## 🚀 Quick Start

### 1. Prerequisites
- **GameGuardian** installed.
- **Portrait Orientation** (Locked).
- **Navigation Bar**: 3-button layout recommended for No-Root.
- **Permissions**: Accessibility (for No-Root gestures) or Root access.

### 2. Installation
1. Clone this repository or copy the `src/` folder to your device storage (e.g., `/sdcard/BunnyRunner/`).

### 3. First Run & Calibration
1. Launch **Bunny Runner 3D**.
2. Open **GameGuardian** and attach it to the game.
3. Execute `src/main.lua`.
4. **Follow the Calibration Wizard**:
   - **Step 1**: Mark your App Icon on the Home Screen.
   - **Step 2**: Capture the Path Color DNA on the game's start screen.
5. Click **🚀 RUN BOT**.

---

## ⚙️ Pro-Tips for Reliability

- **Do Not Disturb**: Turn this ON! Notifications can block pixels and cause the bot to miss a turn.
- **Zero Filters**: Turn off "Blue Light Filter" or "Night Mode" for 100% accurate color detection.
- **No Battery Saver**: Android often caps the CPU in power-saving mode, causing the bot to lag during turns.
- **Home Screen**: Keep the Bunny Runner icon on your main home page for reliable relaunching.

---

## 📁 Project Structure

```text
src/
├── main.lua                # Bulletproof Entry Point & State Machine
├── core/
│   ├── wizard.lua          # Intelligent Calibration Wizard
│   ├── vision.lua          # Fuzzy Vision & State Detection
│   ├── vision_auto.lua     # Automated UI Scanning (Button DNA)
│   ├── gestures.lua        # Human-like Reset Emulation (No-Root)
│   ├── reset.lua           # High-speed Shell Reset (Root)
│   └── permissions.lua     # Accessibility Guard & Setup Guide
└── ui/
    └── dashboard.lua       # Status Display & Advanced Settings
```

---

## 📺 Dashboard Controls

- **🚀 RUN BOT**: Start the state machine.
- **🤖 Auto-Scan**: Automatically locate the Play/Next buttons.
- **🔄 Switch Mode**: Toggle between `ROOT` and `HUMAN` (No-Root).
- **🏠 Calibrate Icon**: Set the relaunch target for Human Resets.
- **Emergency Stop**: Press **Volume Down** at any time.

---

## 📝 License
MIT License - Feel free to build upon this work.

---
**Made with ❤️ for the Bunny Runner Community**
