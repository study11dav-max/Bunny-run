[app]
title = Bunny Bot
package.name = bunnybot
package.domain = org.bunnybot
source.dir = .
source.include_exts = py,png,jpg,kv,atlas
version = 1.0

# Requirements
requirements = python3, kivy, numpy, python-opencv-lite, android

# Permissions
android.permissions = SYSTEM_ALERT_WINDOW, WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE, INTERNET

# (list) Supported orientations
orientation = portrait

# (list) List of service to declare
# services = BunnyService:service.py

# (str) Icon of the application
# icon.filename = %(source.dir)s/data/icon.png

# (list) Android additional libraries
# android.add_libs_armeabi_v7a = libs/armeabi-v7a/libopencv_java3.so

[buildozer]
log_level = 2
warn_on_root = 1
