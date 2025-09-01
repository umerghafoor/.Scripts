#!/bin/bash
mode=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$mode" == "'prefer-dark'" ]; then
    gsettings set org.gnome.desktop.interface icon-theme 'Reversal_by_umer'
else
    gsettings set org.gnome.desktop.interface icon-theme 'Reversal_by_umer'
fi

