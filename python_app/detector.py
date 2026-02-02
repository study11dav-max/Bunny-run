import cv2
import numpy as np
import os

class Detector:
    def __init__(self, assets_path="assets/"):
        self.assets_path = assets_path
        self.templates = {}
        self.load_templates()

    def load_templates(self):
        """Loads button templates for matching"""
        template_files = {
            "START_BTN": "starting_btn.jpg",
            "WIN_NEXT": "winning_btn.jpg",
            "GAME_OVER": "ending_re.jpg"
        }
        for key, filename in template_files.items():
            path = os.path.join(self.assets_path, filename)
            if os.path.exists(path):
                self.templates[key] = cv2.imread(path, 0) # Load in grayscale
            else:
                print(f"⚠️ Warning: Template {filename} not found.")

    def match_template(self, screenshot, template_key, threshold=0.8):
        """Returns True if the template is found on screen with high confidence"""
        if template_key not in self.templates:
            return False
        
        gray_screen = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
        template = self.templates[template_key]
        
        res = cv2.matchTemplate(gray_screen, template, cv2.TM_CCOEFF_NORMED)
        _, max_val, _, _ = cv2.minMaxLoc(res)
        
        return max_val > threshold

    def check_sensors(self, screenshot):
        """
        Implementation of the dual 'White Fence' sensors.
        Returns 'TURN' if either sensor detects white fence (0xFFFFFF).
        """
        h, w = screenshot.shape[:2]
        
        # Sensor A (Left) and Sensor B (Right)
        # Using normalized coordinates for resolution independence
        left_x, sensor_y = int(w * 0.42), int(h * 0.65)
        right_x = int(w * 0.58)
        
        # Get pixel colors (OpenCV uses BGR)
        left_pixel = screenshot[sensor_y, left_x]
        right_pixel = screenshot[sensor_y, right_x]
        
        def is_white(pixel, threshold=230):
            # Check if all channels are high (White)
            return all(c > threshold for c in pixel)

        if is_white(left_pixel) or is_white(right_pixel):
            return True
            
        return False

    def get_state(self, screenshot):
        """Determines the current game state using templates"""
        if self.match_template(screenshot, "START_BTN"):
            return "START_SCREEN"
        if self.match_template(screenshot, "WIN_NEXT") or self.match_template(screenshot, "GAME_OVER"):
            return "END_SCREEN"
        return "IN_GAME"
