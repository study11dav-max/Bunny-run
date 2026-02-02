from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.clock import Clock
from kivy.core.window import Window
import android_utils
from detector import Detector
import threading
import time

# Note: On actual Android, you'd use a background Service if possible,
# but for the APK interface, we provide a clean start/stop controller.

class BunnyBotApp(App):
    def build(self):
        self.title = "Bunny Runner Standalone Bot"
        self.running = False
        self.detector = Detector()
        
        layout = BoxLayout(orientation='vertical', padding=20, spacing=20)
        
        self.status_label = Label(text="Bot Status: IDLE", font_size='20sp', color=(1,1,1,1))
        layout.add_widget(self.status_label)
        
        self.toggle_btn = Button(text="🚀 START BOT", font_size='24sp', background_color=(0, 0.7, 1, 1))
        self.toggle_btn.bind(on_press=self.toggle_bot)
        layout.add_widget(self.toggle_btn)
        
        info_text = "Instructions:\n1. Open Bunny Runner\n2. Grant Screen Capture & Accessibility\n3. Click Start above\n4. Kill Switch: Stop in this App"
        layout.add_widget(Label(text=info_text, font_size='14sp', halign='center'))
        
        return layout

    def toggle_bot(self, instance):
        if not self.running:
            self.running = True
            self.toggle_btn.text = "🛑 STOP BOT"
            self.toggle_btn.background_color = (1, 0, 0, 1)
            self.status_label.text = "Bot Status: RUNNING"
            # Start the logic in a background thread to keep UI responsive
            threading.Thread(target=self.automation_loop, daemon=True).start()
        else:
            self.running = False
            self.toggle_btn.text = "🚀 START BOT"
            self.toggle_btn.background_color = (0, 0.7, 1, 1)
            self.status_label.text = "Bot Status: IDLE"

    def automation_loop(self):
        """The core loop migrating the Lua logic to Python/OpenCV"""
        print("🐰 BunnyBot: Automated Python Flow Started")
        
        while self.running:
            # 1. Capture Screen (Placeholder for native Android capture)
            # screen = capture_android_screen()
            # For demonstration, we assume we have a pixel access method 
            # In a real APK, we'd use MediaProjection or similar.
            
            # Simple simulation of state machine logic:
            # state = self.detector.get_state(screen)
            
            # For now, we print to log as the actual capture requires JNI/Android context
            # that is typically handled by the compiled buildozer framework.
            
            # if state == "START_SCREEN":
            #     android_utils.tap(540, 1900) # Play center
            #     time.sleep(2)
            # elif state == "END_SCREEN":
            #     android_utils.ad_dodge_reset()
            # elif state == "IN_GAME":
            #     if self.detector.check_sensors(screen):
            #         android_utils.tap(540, 1200) # Jump/ZigZag tap
            #         time.sleep(0.15)
            
            time.sleep(0.1) # Frequency control

    def on_stop(self):
        self.running = False

if __name__ == "__main__":
    BunnyBotApp().run()
