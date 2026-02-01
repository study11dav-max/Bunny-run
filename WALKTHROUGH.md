# 🎮 Bunny Runner Bot - Complete Walkthrough

## 📋 Table of Contents
- [Setup Guide](#setup-guide)
- [Dashboard Tutorial](#dashboard-tutorial)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)

## 🚀 Setup Guide

### Step 1: Installation

**Option A: Using ADB**
```bash
adb push src/ /sdcard/BunnyRunner/
```

**Option B: Manual Transfer**
1. Connect device to PC
2. Copy the `src` folder to `/sdcard/BunnyRunner/`

### Step 2: Permissions

Grant GameGuardian the following permissions:
- ✅ Display Over Other Apps
- ✅ Accessibility Service (or Root)

### Step 3: Performance Setup

**Critical**: Turn OFF Battery Saver mode
- Settings → Battery → Battery Saver → OFF
- This ensures smooth frame rates for accurate detection

### Step 4: Launch Sequence

1. Open **Bunny Runner 3D** first
2. Open **GameGuardian**
3. Attach GG to Bunny Runner process
4. Execute `/sdcard/BunnyRunner/src/main.lua`

## 📊 Dashboard Tutorial

### First Time Setup

When you first launch, you'll see:

```
--- SETUP STATUS ---
1. Path Color: ❌
2. Restart Button: ❌
--------------------
```

Both steps must be completed before running the bot.

### 🎨 Step 1: Calibrate Path

**Purpose**: Teaches the bot what the safe path looks like

**Instructions**:
1. Start a match in Bunny Runner
2. **PAUSE** the game (important!)
3. Make sure the bunny is on the path
4. Select **🎨 Step 1: Calibrate Path**
5. Press OK

**What happens**: The bot samples the pixel color at the center of the screen (65% height - the "sweet spot")

**Result**: Status updates to ✅

### 💀 Step 2: Calibrate Restart

**Purpose**: Teaches the bot where to click when you die

**Instructions**:
1. Resume the game
2. Let the bunny die (crash into a fence)
3. Wait for the **RESTART** button to appear
4. Select **💀 Step 2: Calibrate Restart**
5. Enter the X and Y coordinates of the restart button
   - **Tip**: Use a screen coordinate app or estimate (usually center-bottom)
   - Default suggestion: X = screen width / 2, Y = screen height * 0.75

**Result**: Status updates to ✅

### 🚀 Running the Bot

Once both steps show ✅:

1. Select **🚀 RUN BOT**
2. The dashboard closes
3. Bot takes control
4. Handles zigzag automatically
5. Auto-restarts on death

**To Stop**: Press **Volume Down** button

## 🔧 Troubleshooting

### Problem: Bot turns too late

**Symptom**: Bunny crashes into fences

**Solution**:
1. Open dashboard
2. Select **⚙️ Advanced Settings**
3. Increase **Detection Height** from 65 to 70
4. Save and re-run

### Problem: Bot turns randomly (false triggers)

**Symptom**: Bunny zigzags when path is clear

**Solution**:
1. Open dashboard
2. Select **⚙️ Advanced Settings**
3. Decrease **Color Tolerance** from 5000 to 3000
4. Save and re-run

### Problem: Bot double-taps (turns twice quickly)

**Symptom**: Bunny turns left-right-left rapidly

**Solution**:
1. Open dashboard
2. Select **⚙️ Advanced Settings**
3. Increase **Refractory Period** from 150ms to 200ms
4. Save and re-run

### Problem: Auto-restart doesn't work

**Symptom**: Bot stops when you die

**Solution**:
1. Re-run **Step 2: Calibrate Restart**
2. Use exact coordinates of the restart button
3. **Tip**: Take a screenshot, use a coordinate finder app

### Problem: Bot is laggy

**Symptom**: Delayed reactions

**Solution**:
1. Close background apps
2. Ensure Battery Saver is OFF
3. Lower game graphics settings
4. Check device temperature (overheating causes throttling)

## ⚙️ Advanced Configuration

### Detection Height Explained

The bot checks pixels at a specific Y-position on the screen:

- **60%**: Very early detection (may trigger on camera movement)
- **65%**: Sweet spot (recommended)
- **70%**: Late detection (good for fast reactions)
- **75%**: Very late (only for high-level play)

### Color Tolerance Explained

How different a pixel can be from the path color:

- **3000**: Strict (only exact matches)
- **5000**: Balanced (recommended)
- **10000**: Loose (tolerates shadows/lighting)
- **15000**: Very loose (may cause false triggers)

### Refractory Period Explained

Delay after each tap to prevent double-tapping:

- **100ms**: Fast (risk of double-taps)
- **150ms**: Balanced (recommended)
- **200ms**: Safe (prevents all double-taps)
- **250ms**: Very safe (may feel sluggish)

## 📖 Tutorial (Built-in)

Access via **📖 View Tutorial / Help** in the dashboard for quick reference.

## 🎯 Pro Tips

1. **Sweet Spot Science**: The 60-70% height avoids:
   - Top: Camera shake and movement
   - Bottom: Bunny character blocking view

2. **Luminance Detection**: The bot uses brightness, not exact colors:
   - Works in different lighting
   - Adapts to shadows
   - More reliable than RGB matching

3. **State Locking**: The bot knows which direction you're moving:
   - Only checks the relevant fence
   - Cuts CPU usage in half
   - Prevents accidental double-turns

4. **Emergency Stop**: Volume Down works even if screen is off

## 📱 Device Compatibility

**Tested on**:
- Android 7.0+
- Screen resolutions: 720p to 1440p
- GameGuardian 101.0+

**Requirements**:
- Root OR Virtual Space (e.g., Parallel Space)
- 2GB+ RAM
- Stable 30+ FPS in game

---

**Need help?** Check the README.md or open an issue on GitHub!
