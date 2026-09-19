#!/usr/bin/env zsh

#stop the script if an error occurs
set -e

#run a command with administrator privileges
run_as_root() {
    if (( EUID == 0 )); then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        return 1
    fi
}

#install a package using the available package manager
install_package() {
    local package="$1"

    if command -v pacman >/dev/null 2>&1; then
        run_as_root pacman -S --needed --noconfirm "$package"
    elif command -v apt-get >/dev/null 2>&1; then
        run_as_root apt-get update
        run_as_root apt-get install -y "$package"
    elif command -v dnf >/dev/null 2>&1; then
        run_as_root dnf install -y "$package"
    elif command -v apk >/dev/null 2>&1; then
        run_as_root apk add "$package"
    elif command -v zypper >/dev/null 2>&1; then
        run_as_root zypper --non-interactive install "$package"
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

#paths to the source plugin, installed plugin and zsh configuration
source_plugin_path="${0:A:h}/nexus.plugin.zsh"
plugin_path="$HOME/Nexus/nexus.plugin.zsh"
zshrc_path="$HOME/.zshrc"
source_line='[[ -f "$HOME/Nexus/nexus.plugin.zsh" ]] && source "$HOME/Nexus/nexus.plugin.zsh"'

#check that the source plugin exists
if [[ ! -f "$source_plugin_path" ]]; then
    print -u2 "Error: plugin not found at $source_plugin_path"
    exit 1
fi

#copy the plugin to the installation directory
mkdir -p "${plugin_path:h}"
if ! cmp -s "$source_plugin_path" "$plugin_path" 2>/dev/null; then
    cp "$source_plugin_path" "$plugin_path"
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
