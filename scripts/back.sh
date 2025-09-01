#!/bin/bash

BACKUP_DIR="$HOME/linux-settings-backup"
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
DCONF_FILE="$BACKUP_DIR/dconf-settings.ini"
EXTENSIONS_LIST="$BACKUP_DIR/extensions-list.txt"
PACKAGES_LIST="$BACKUP_DIR/packages-list.txt"

mkdir -p "$BACKUP_DIR"

backup() {
    echo "Backing up settings..."

    # Save installed GNOME extensions
    gnome-extensions list > "$EXTENSIONS_LIST"

    # Save GNOME settings
    dconf dump / > "$DCONF_FILE"

    # Save list of installed packages (for Debian-based systems)
    dpkg --get-selections > "$PACKAGES_LIST"

    echo "Backup completed. Files saved in $BACKUP_DIR"
}

restore() {
    echo "Restoring settings..."

    # Restore installed GNOME extensions
    cat "$EXTENSIONS_LIST" | xargs -I {} gnome-extensions install {}

    # Restore GNOME settings
    dconf load / < "$DCONF_FILE"

    # Restore installed packages (for Debian-based systems)
    sudo dpkg --set-selections < "$PACKAGES_LIST"
    sudo apt-get dselect-upgrade -y

    echo "Restore completed."
}

if [ "$1" == "backup" ]; then
    backup
elif [ "$1" == "restore" ]; then
    restore
else
    echo "Usage: $0 {backup|restore}"
fi
