import cv2
import numpy as np
import os

class GameVision:
    def __init__(self, templates_dir="assets/"):
        self.templates_dir = templates_dir
        # Load screenshots as reference templates (must be in assets/ folder)
        self.templates = {}
        self.load_templates()

    def load_templates(self):
        """Loads reference images for state detection."""
        template_files = {
            'play': 'starting_btn.jpg',
            'next': 'winning_btn.jpg',
            'try_again': 'ending_re.jpg'
        }
        for name, filename in template_files.items():
            path = os.path.join(self.templates_dir, filename)
            if os.path.exists(path):
                # Load in grayscale for faster matching
                self.templates[name] = cv2.imread(path, 0)
            else:
                print(f"⚠️ Warning: Template {filename} not found in {self.templates_dir}")

    def detect_state(self, screenshot):
        """Detects which screen we are on using 90% accuracy threshold."""
        if not self.templates:
            return "IN_GAME", None

        # Convert screenshot to grayscale
        gray_frame = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
        
        for name, template in self.templates.items():
            res = cv2.matchTemplate(gray_frame, template, cv2.TM_CCOEFF_NORMED)
            _, max_val, _, max_loc = cv2.minMaxLoc(res)
            
            if max_val > 0.9: # 90% match
                return name, max_loc
        
        return "IN_GAME", None

    def find_path_edge(self, screenshot):
        """Uses Canny Edge Detection to find the white fences."""
        # Convert to grayscale
        gray = cv2.cvtColor(screenshot, cv2.COLOR_BGR2GRAY)
        # Apply Canny Edge Detection
        # Thresh 50-150 is a good baseline for bright white fences
        edges = cv2.Canny(gray, 50, 150)
        return edges

    def check_fence_collision(self, edges, x, y):
        """Checks if a specific point (x, y) contains an edge (fence)."""
        # Ensure coordinates are within image bounds
        h, w = edges.shape
        if 0 <= x < w and 0 <= y < h:
            return edges[y, x] > 0
        return False
