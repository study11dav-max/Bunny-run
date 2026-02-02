import cv2
import time
import os
from vision import GameVision
from controller import AndroidController

# Configuration
SCREENSHOT_PATH = "/sdcard/bunny_screen.png"

def main():
    print("🐰 BunnyBot Standalone (Python Edition) Started")
    vision = GameVision(templates_dir="assets/")
    ctrl = AndroidController(package_name="com.bunny.runner3D.dg")
    
    # Wait for initial game visibility
    time.sleep(2)
    
    while True:
        # 1. Capture the screen using native Android shell
        # In a final Kivy APK, this might be replaced by a faster Buffer/Service capture
        os.system(f"screencap -p {SCREENSHOT_PATH}")
        
        if not os.path.exists(SCREENSHOT_PATH):
            print("⚠️ Error: Failed to capture screen. Waiting...")
            time.sleep(2)
            continue
            
        screen = cv2.imread(SCREENSHOT_PATH)
        if screen is None:
            time.sleep(0.1)
            continue

        h, w = screen.shape[:2]
        state, coords = vision.detect_state(screen)
        
        if state == "play":
            print("🚀 'PLAY' button detected. Clicking...")
            # coords is (x, y) of top-left, tap the middle of the match
            ctrl.tap(coords[0] + 50, coords[1] + 20)
            time.sleep(2) # Wait for level to load
            
        elif state == "next" or state == "try_again":
            print(f"🏁 Screen Detected: {state}. Triggering Ad-Dodge Reset...")
            ctrl.swipe_to_close()
            ctrl.relaunch_game()
            time.sleep(6) # Wait for cold boot
            
        elif state == "IN_GAME":
            # Robust zigzag logic using path edges (Canny)
            edges = vision.find_path_edge(screen)
            
            # Use normalized sensors (based on 1080p reference)
            # Sensors check for edge lines (white fences)
            sensor_y = int(h * 0.65)
            left_sensor_x = int(w * 0.42)
            right_sensor_x = int(w * 0.58)
            
            # If we hit an edge (fence) with either sensor, tap to turn
            if vision.check_fence_collision(edges, left_sensor_x, sensor_y) or \
               vision.check_fence_collision(edges, right_sensor_x, sensor_y):
                print("🚧 Fence detected! Turning...")
                ctrl.tap(w // 2, h // 2)
                time.sleep(0.15) # Refractory period
        
        # Frequency limit to avoid CPU throttling
        time.sleep(0.05)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n🛑 Bot stopped by user.")
