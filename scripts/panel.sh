#!/bin/bash

# Check argument
if [[ "$1" == "panel" ]]; then
    echo "Switching to Dash to Panel..."
    gnome-extensions enable dash-to-panel@jderose9.github.com
    gnome-extensions disable ubuntu-dock@ubuntu.com

    echo "Enabling Arc Menu..."
    gnome-extensions enable arcmenu@arcmenu.com

    echo "Disabling App Icon Task Bar..."
    gnome-extensions disable aztaskbar@aztaskbar.gitlab.com

    echo "Disabling Show Desktop Button..."
    gnome-extensions disable show-desktop-button@amivaleo

elif [[ "$1" == "dock" ]]; then
    echo "Switching to Ubuntu Dock..."
    gnome-extensions enable ubuntu-dock@ubuntu.com
    gnome-extensions disable dash-to-panel@jderose9.github.com

    echo "Disabling Arc Menu..."
    gnome-extensions disable arcmenu@arcmenu.com

    echo "Enabling App Icon Task Bar..."
    gnome-extensions enable aztaskbar@aztaskbar.gitlab.com

    echo "Enabling Show Desktop Button..."
    gnome-extensions enable show-desktop-button@amivaleo

else
    echo "Usage: $0 [panel|dock]"
    exit 1
fi

