
#!/bin/bash

# --- CONFIGURE YOUR SCRIPT/COMMAND HERE ---
run_my_script() {
    echo "Dark mode enabled → running script..."
    # replace below line with your actual script or command
    /path/to/your/script.sh
}

# --- CHECK AT STARTUP ---
mode=$(gsettings get org.gnome.desktop.interface color-scheme)
if [ "$mode" = "'prefer-dark'" ]; then
    run_my_script
fi

# --- LISTEN FOR CHANGES ---
gsettings monitor org.gnome.desktop.interface color-scheme | while read -r; do
    mode=$(gsettings get org.gnome.desktop.interface color-scheme)
    if [ "$mode" = "'prefer-dark'" ]; then
        run_my_script
    fi
done
