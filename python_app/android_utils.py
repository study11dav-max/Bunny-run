import os
import time

# Bundle ID for Bunny Runner
PACKAGE_NAME = "com.bunny.runner3D.dg"

def tap(x, y):
    """Performs a native tap via shell"""
    os.system(f"input tap {x} {y}")

def swipe(x1, y1, x2, y2, duration):
    """Performs a native swipe via shell"""
    os.system(f"input swipe {x1} {y1} {x2} {y2} {duration}")

def ad_dodge_reset(icon_x=540, icon_y=450):
    """
    Performs the Ad-Skip reset:
    1. Opens Recents
    2. Swipes away the game
    3. Relaunches from Home Screen
    """
    print("🖐️ Performing Human Reset...")
    
    # 1. Open Recent Apps (Keycode 187 is APP_SWITCH)
    os.system("input keyevent 187")
    time.sleep(1.2)
    
    # 2. Dismiss the Game (Center swipe to right)
    # Adjust coordinates based on typical device center
    swipe(540, 1000, 1000, 1000, 400)
    time.sleep(1.0)
    
    # 3. Tap Home Button (Keycode 3 is HOME)
    os.system("input keyevent 3")
    time.sleep(1.0)
    
    # 4. Tap the App Icon on Home Screen (Relaunch)
    tap(icon_x, icon_y)
    print("🚀 Relaunching Bunny Runner...")
    
    time.sleep(6.0) # Wait for splash screen

def relaunch_via_intent():
    """Relaunches the app directly via intent (might not skip ads as effectively)"""
    os.system(f"monkey -p {PACKAGE_NAME} -c android.intent.category.LAUNCHER 1")
