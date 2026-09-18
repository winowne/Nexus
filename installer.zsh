#!/usr/bin/env zsh

#stop the script if an error occurs
set -e

#install a package using the available package manager
install_package() {
    local package="$1"

    if (( EUID == 0 )); then
        if command -v pacman >/dev/null 2>&1; then
            pacman -S --needed --noconfirm "$package"
        elif command -v apt-get >/dev/null 2>&1; then
            apt-get update
            apt-get install -y "$package"
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y "$package"
        else
            return 1
        fi
    elif command -v sudo >/dev/null 2>&1; then
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm "$package"
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y "$package"
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y "$package"
        else
            return 1
        fi
    elif command -v brew >/dev/null 2>&1; then
        brew install "$package"
    else
        return 1
    fi
}

#check that jq is installed
if ! command -v jq >/dev/null 2>&1; then
    print "jq was not found. Installing jq..."
    if ! install_package jq; then
        print -u2 "Error: could not install jq"
        exit 1
    fi
fi

#paths to the plugin and zsh configuration
plugin_path="$HOME/Nexus/nexus.plugin.zsh"
zshrc_path="$HOME/.zshrc"
source_line='[[ -f "$HOME/Nexus/nexus.plugin.zsh" ]] && source "$HOME/Nexus/nexus.plugin.zsh"'

#check that the plugin exists
if [[ ! -f "$plugin_path" ]]; then
    print -u2 "Error: plugin not found at $plugin_path"
    exit 1
fi

#create the zsh configuration if it does not exist
touch "$zshrc_path"

#add the plugin to zsh configuration if it is not already there
if ! grep -Fqx "$source_line" "$zshrc_path"; then
    print -r -- "$source_line" >> "$zshrc_path"
fi

#load the plugin
source "$plugin_path"
#show the installation result
print "Nexus installed. Restart Zsh or run: source ~/.zshrc"
