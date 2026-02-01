# Project: Bunny Runner Automator (BR-Auto)

## 1. Project Objective
Create a standalone Lua-driven automation tool for "Bunny Runner 3D" that utilizes a floating UI panel to start/stop the script. The goal is to automate the zigzag turns to achieve "Infinite Run" status without manual input.

## 2. Core Functionality
* **Floating Overlay Panel:** A movable UI with "Start," "Stop," and "Speed Adjustment" buttons.
* **Path Detection:** High-speed pixel scanning at specific coordinates (Screen X/Y) to detect when the bunny reaches a fence boundary.
* **Input Simulation:** Executes a screen tap to change direction immediately upon detection.
* **Adaptive Timing:** Logic to handle the increasing game speed by narrow the detection window as the score rises.

## 3. Project Roadmap
### Phase 1: Environment Setup
* Initialize project in **Google Antigravity IDE**.
* Configure the Android environment (ADB over Wi-Fi or local terminal).

### Phase 2: Logic Development
* **Calibration:** Identify the exact RGB values of the fences vs. the path.
* **Loop:** Implement a high-frequency `while true` loop for detection.
* **Input:** Map `device.tap(x, y)` functions.

### Phase 3: UI Design
* Build the Lua-based panel (using the `gg.showMenu` or `Canvas` API depending on the runner).

### Phase 4: Testing & Optimization
* Run tests on Levels 1, 20, and 40+.
* Fine-tune detection "look-ahead" distance to compensate for lag.

## 4. Success Criteria
* Bunny completes Level 50 without user intervention.
* Script remains stable for >30 minutes of continuous play.
