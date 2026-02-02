import os
import time

class AndroidController:
    def __init__(self, package_name="com.bunny.runner3D.dg"):
        self.package_name = package_name

    def tap(self, x, y):
        """Native tap via Android shell."""
        os.system(f"input tap {x} {y}")

    def swipe(self, x1, y1, x2, y2, duration=400):
        """Native swipe via Android shell."""
        os.system(f"input swipe {x1} {y1} {x2} {y2} {duration}")

    def swipe_to_close(self):
        """The 'Human' method to kill the app and bypass ads."""
        print("🚫 Ad-Dodge Reset triggered!")
        # 1. Open Recents (Keycode 187)
        os.system("input keyevent 187") 
        time.sleep(1.2)
        
        # 2. Swipe card away to kill app (Usually center-to-side or center-to-top)
        # Using a vertical swipe as per the user's robust logic suggestion
        self.swipe(540, 1200, 540, 200, 400)
        time.sleep(1.0)
        
        # 3. Go Home (Keycode 3)
        os.system("input keyevent 3")
        time.sleep(0.5)

    def relaunch_game(self):
        """Restarts the game from the launcher using the monkey tool."""
        print(f"🚀 Relaunching {self.package_name}...")
        os.system(f"monkey -p {self.package_name} -c android.intent.category.LAUNCHER 1")
