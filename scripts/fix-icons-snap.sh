#!/bin/bash

# Path to the .desktop files
desktop_files=("/var/lib/snapd/desktop/applications/code_code.desktop" "/var/lib/snapd/desktop/applications/code_code-url-handler.desktop" "/var/lib/snapd/desktop/applications/gnome-boxes_gnome-boxes.desktop" "/var/lib/snapd/desktop/applications/obsidian_obsidian.desktop" "/var/lib/snapd/desktop/applications/discord_discord.desktop")

# Loop through each file and update the icon path
for desktop_file in "${desktop_files[@]}"; do
    if [[ -f "$desktop_file" ]]; then
        sed -i 's|Icon=/snap/code/[0-9]*/meta/gui/vscode.png|Icon=vscode.svg|g' "$desktop_file"
        sed -i 's|Icon=/snap/gnome-boxes/[0-9]*/meta/gui/icon.svg|Icon=boxes.svg|g' "$desktop_file"
        sed -i 's|Icon=/snap/obsidian/[0-9]*/meta/gui/icon.png|Icon=obsidian.svg|g' "$desktop_file"
        sed -i 's|Icon=/snap/discord/[0-9]*/meta/gui/icon.png|Icon=discord.svg|g' "$desktop_file"
        echo "Icon path updated in: $desktop_file"
    else
        echo "Error: File not found: $desktop_file"
    fi
done
