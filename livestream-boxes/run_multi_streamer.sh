#!/bin/sh

# Not working? Have you installed multi-streamer?
# sudo flatpak install io.volkert.multi_streamer.flatpakref

echo "Running "systemctl --user restart pipewire.service" - this could take a few minutes"
systemctl --user restart pipewire.service

flatpak run io.volkert.multi_streamer
