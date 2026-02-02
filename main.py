import cv2
import time
import os
import threading
from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from core.vision import GameVision
from core.controller import AndroidController
from core.wizard import Wizard
from core.vision_auto import VisionAuto
from core.permissions import Permissions
from ui.dashboard import Dashboard

class MainScreen(Screen):
    def __init__(self, app, **kwargs):
        super().__init__(**kwargs)
        self.app = app
        self.dashboard = Dashboard(
            config=self.app.config_data,
            on_run=self.app.start_bot,
            on_calibrate=self.app.calibrate_path,
            on_scan=self.app.scan_ui
        )
        self.add_widget(self.dashboard)

class BunnyBotApp(App):
    def build(self):
        self.config_data = Wizard().load_config() or Wizard().get_default_config()
        self.vision = GameVision()
        self.controller = AndroidController()
        self.running = False
        
        self.sm = ScreenManager()
        self.sm.add_widget(MainScreen(self, name='main'))
        return self.sm

    def start_bot(self, instance):
        if not self.running:
            self.running = True
            threading.Thread(target=self.bot_loop, daemon=True).start()
            print("🚀 Bot thread started")
        else:
            self.running = False
            print("🛑 Bot stopped")

    def calibrate_path(self, instance):
        threading.Thread(target=self._do_calibrate, daemon=True).start()

    def _do_calibrate(self):
        new_color = Wizard().passive_path_gatherer(self.vision, self.capture_screen)
        self.config_data["path_color"] = new_color
        Wizard().save_config(self.config_data)

    def scan_ui(self, instance):
        threading.Thread(target=self._do_scan, daemon=True).start()

    def _do_scan(self):
        VisionAuto().auto_locate(self.capture_screen)

    def capture_screen(self):
        """Native screen capture integration"""
        os.system("screencap -p /sdcard/screen.png")
        return cv2.imread("/sdcard/screen.png")

    def bot_loop(self):
        while self.running:
            screen = self.capture_screen()
            if screen is not None:
                state, coords = self.vision.detect_state(screen)
                if state == "play":
                    self.controller.tap(coords[0], coords[1])
                elif state == "next" or state == "try_again":
                    self.controller.swipe_to_close()
                    self.controller.relaunch_game()
                    time.sleep(6)
                elif state == "IN_GAME":
                    edges = self.vision.find_path_edge(screen)
                    # Logic using Canny edges...
                    
            time.sleep(0.1)

if __name__ == "__main__":
    BunnyBotApp().run()
