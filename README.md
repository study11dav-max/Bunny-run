# 🐰 Bunny Runner 3D - Auto Bot

A professional automation tool for **Bunny Runner 3D** built with Lua for GameGuardian. Features intelligent zigzag detection, auto-restart on death, and a guided setup dashboard.

## ✨ Features

- **🎯 Smart Detection**: Luminance-based path detection (adaptive to lighting)
- **🔄 Auto-Restart**: Automatically clicks restart when you die
- **📊 Professional Dashboard**: Guided setup with status tracking
- **⚙️ Advanced Settings**: Customizable detection height, tolerance, and timing
- **🛡️ Safe**: Volume Down emergency stop anytime
- **📱 Device Agnostic**: Works on any screen resolution

## 🚀 Quick Start

### Prerequisites

1. **GameGuardian** installed on Android device
2. **Permissions**:
   - Display Over Other Apps
   - Accessibility (or Root access)
3. **Performance**: Turn OFF Battery Saver mode

### Installation

```bash
# Transfer files to your device
adb push src/ /sdcard/BunnyRunner/

# Or manually copy the 'src' folder to your device
```

### First Run

1. Open **Bunny Runner 3D**
2. Open **GameGuardian** and attach to the game
3. Execute `/sdcard/BunnyRunner/src/main.lua`
4. Follow the **Dashboard Setup**:
   - ✅ **Step 1**: Calibrate Path (pause on track, press OK)
   - ✅ **Step 2**: Calibrate Restart (die, enter button coordinates)
   - 🚀 **Run Bot** (once both steps are complete)

## 📖 Usage

### Dashboard Menu

```
--- SETUP STATUS ---
1. Path Color: ✅
2. Restart Button: ✅
--------------------

🚀 RUN BOT (Ready: YES)
🎨 Step 1: Calibrate Path
💀 Step 2: Calibrate Restart
📖 View Tutorial / Help
⚙️ Advanced Settings
❌ Close Panel
```

### Controls

- **Volume Down**: Emergency stop during run
- **Dashboard**: Re-calibrate or adjust settings anytime

## ⚙️ Advanced Settings

Access via the dashboard to fine-tune performance:

| Setting | Default | Description |
|---------|---------|-------------|
| Detection Height | 65% | Y-position for path detection (60-70% recommended) |
| Color Tolerance | 5000 | Sensitivity to color differences |
| Refractory Period | 150ms | Delay after each tap to prevent double-taps |

## 💡 Pro Tips

- **Sweet Spot**: 60-70% screen height is optimal for detection
- **Luminance Detection**: Uses brightness thresholds, not exact colors
- **Frame Rate**: Disable Battery Saver for smooth performance
- **Troubleshooting**:
  - Turns too late? → Increase Detection Height
  - False triggers? → Decrease Color Tolerance
  - Double-taps? → Increase Refractory Period

## 📁 Project Structure

```
src/
├── main.lua              # Main entry point with dashboard loop
├── core/
│   ├── wizard.lua        # Step-by-step calibration functions
│   ├── detector.lua      # Legacy detection logic
│   ├── calibration.lua   # Legacy calibration module
│   ├── input.lua         # Input simulation helpers
│   └── recovery.lua      # Legacy auto-restart module
└── ui/
    ├── dashboard.lua     # Professional status dashboard
    └── panel.lua         # Legacy UI panel
```

## 🔧 How It Works

1. **Path Detection**: Samples pixel color at the "sweet spot" (65% screen height)
2. **Zigzag Logic**: State-locked detection (only checks relevant side based on direction)
3. **Auto-Restart**: Monitors restart button position for death screen
4. **Adaptive**: Uses luminance thresholds instead of exact color matching

## 📝 License

MIT License - Feel free to modify and distribute

## 🤝 Contributing

Contributions welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## ⚠️ Disclaimer

This tool is for educational purposes. Use responsibly and in accordance with the game's terms of service.

---

**Made with ❤️ for the Bunny Runner community**
