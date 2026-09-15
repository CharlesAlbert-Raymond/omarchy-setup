#!/bin/sh
# GUI + CLI for V4L2 webcam controls (exposure, gain, focus, ...), built with
# Logitech cameras in mind. Omarchy has no picture-settings UI of its own.
# Open the C920 with: cameractrlsgtk4 -d /dev/video4

yay -S --noconfirm --needed cameractrls
