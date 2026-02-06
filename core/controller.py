import os
import time
import subprocess

class AndroidController:
    def __init__(self, package_name="com.bunny.runner3D.dg"):
        self.package_name = package_name
        # Start a persistent shell process
        self.shell = subprocess.Popen(
            ['sh'],
            stdin=subprocess.PIPE,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1
        )

    def _run_cmd(self, cmd):
        """Writes a command to the persistent shell's stdin."""
        try:
            if self.shell.poll() is not None:
                # Restart shell if it died
                self.__init__(self.package_name)
            
            if self.shell.stdin is None:
                raise BrokenPipeError("Shell stdin is not available")

            self.shell.stdin.write(cmd + "\n")
            # Flushing is critical for the command to execute immediately
            self.shell.stdin.flush()
        except BrokenPipeError:
            # Handle broken pipe if shell crashes
            self.__init__(self.package_name)

    def tap(self, x, y):
        """Native tap via persistent shell."""
        self._run_cmd(f"input tap {x} {y}")

    def swipe(self, x1, y1, x2, y2, duration=400):
        """Native swipe via persistent shell."""
        self._run_cmd(f"input swipe {x1} {y1} {x2} {y2} {duration}")

    def swipe_to_close(self):
        """The 'Human' method to kill the app and bypass ads."""
        print("🚫 Ad-Dodge Reset triggered!")
        
        # Kernel-level Force Stop
        self._run_cmd(f"am force-stop {self.package_name}")
        time.sleep(1.0)
        
        # Fallback to gestured clearing if force-stop is restricted
        self._run_cmd("input keyevent 187") # Open Recents
        time.sleep(1.0)
        self.swipe(540, 1200, 540, 200, 400) # Swipe Card
        time.sleep(0.5)

        # Go Home
        self._run_cmd("input keyevent 3")
        time.sleep(0.5)

    def relaunch_game(self):
        """Restarts the game from the launcher using the monkey tool."""
        print(f"🚀 Relaunching {self.package_name}...")
        self._run_cmd(f"monkey -p {self.package_name} 1")
