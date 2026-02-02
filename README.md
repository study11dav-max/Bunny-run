# 🐰 Bunny Bot: Standalone Python APK (Zero-PC Release)

A professional, standalone Android automation app for **Bunny Runner 3D**, built with Python, Kivy, and OpenCV. This version replaces the legacy Lua codebase, eliminating the need for GameGuardian and offering a superior, one-click experience.

---

## ✨ Features (The Python Suite)

- **🖼️ OpenCV Vision Engine**: Uses **Template Matching** (90% confidence) for reliable state detection (Starting, Winning, Ending).
- **🏳️‍🌈 White Fence Sensors**: High-stability path detection using **Canny Edge Detection** instead of fragile pixel-color matching.
- **📱 Standalone Controller**: A hardware-level interface for Android that performs taps and "Human-Like" ad-dodging swipes directly via shell commands.
- **🧙 Intelligent Calibration**: Built-in Python wizard for passive path DNA sampling and automated UI scanning.
- **🛑 Safe-Exit Kill Switch**: One-tap shutdown and emergency stop (Volume Down support).

---

## 🏗️ Architecture

The app is built using a modular Python architecture designed for performance and reliability on Android:

### Core Modules (`core/`)
- **`vision.py`**: The "Eyes". Implements Template Matching and Canny edge analysis.
- **`controller.py`**: The "Hands". Handles shell-based gestures and ad-dodge resets.
- **`wizard.py`**: The "Brain". Handles configuration persistence (JSON) and calibration.
- **`vision_auto.py`**: The "Scanner". Automatically identifies UI button positions.
- **`permissions.py`**: The "Guard". Manages Accessibility and Overlay setting links.

### UI Layer (`ui/`)
- **`dashboard.py`**: Professional Kivy-based menu with real-time status and advanced settings.

---

## 🚀 Quick Start (For Developers)

### 1. Requirements
- **Python 3.10+**
- **Kivy**
- **OpenCV (cv2)**
- **Numpy**

### 2. Run Locally (Testing)
1. Clone the repository.
2. Run `python main.py`.

### 3. Build the APK
Use **Buildozer** to compile for Android:
```bash
buildozer android debug deploy run
```

---

## 📁 Final Project Structure

```text
.
├── main.py              # Main Kivy Entry Point & App Lifecycle
├── buildozer.spec       # Android Compilation Config
├── assets/              # Template images for OpenCV matching
├── core/                # Business Logic
│   ├── vision.py        # Robust Detection (Edges & Templates)
│   ├── controller.py    # Hardware-level Gestures
│   ├── wizard.py        # Auto-Calibration & JSON Config
│   ├── vision_auto.py    # UI/Button DNA Scanner
│   └── permissions.py   # Android Permission Links
└── ui/
    └── dashboard.py     # Professional Android Menu
```

---

## 📝 License
MIT License - Developed by the Bunny Runner community.

---
**Made with ❤️ for the Bunny Runner Community**
