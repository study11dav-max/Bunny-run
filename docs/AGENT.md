# Build & Test
* **Push to Device:** `adb push ./dist/bunny_script.lua /sdcard/Download/`
* **Run Linter:** `luacheck src/`
* **Test Environment:** Launch via the `Antigravity Browser` or directly on an Android Emulator (Pixel 6 API 34).
* **Execution:** Use the command `lua-executor run ./src/main.lua` to simulate a run in the Antigravity headless terminal.

# Architecture Overview
* **main.lua:** Entry point; initializes the UI and the main execution thread.
* **ui/panel.lua:** Defines the floating window, button styles, and event listeners.
* **core/detector.lua:** Handles `getPixelColor` logic and screen coordinate mapping.
* **core/input.lua:** Handles the `tap` and `swipe` abstractions.

# Git Workflows
* **Branching:** `feature/ui-panel`, `feature/pixel-logic`, `bugfix/speed-lag`.
* **Commits:** Use [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `feat: add pixel detection for level 40+`).
* **PRs:** Require a screenshot of the script running on the Antigravity Browser before merging.

# Conventions & Patterns
* **Naming:** Functions in `camelCase`, constants in `SCREAMING_SNAKE_CASE`.
* **Folder Layout:**
    * `/src`: Core Lua source code.
    * `/assets`: UI icons and reference images for calibration.
    * `/docs`: TASK.md and AGENT.md.
* **Style:** No global variables; use `local` for everything to ensure performance in the Lua VM.

# Best Practices
* **Latency:** Keep the detection loop under 16ms (for 60fps games).
* **Battery:** Use `os.sleep(0.01)` in the loop to prevent phone overheating.
* **Safety:** Add a "Panic Stop" hotkey (e.g., Volume Down) to kill the script instantly.
