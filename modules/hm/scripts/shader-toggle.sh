#!/usr/bin/env bash
# Toggle Hyprland's screen shader between the vibrance shader and HyDE's no-op shader.
# Bound to Mod+Shift+C in modules/hm/hyprland.nix.
#
#   on  -> $XDG_CONFIG_HOME/hypr/shaders/self_vibrance.frag
#   off -> $XDG_CONFIG_HOME/hypr/shaders/disable.frag (falls back to [[EMPTY]])
#
# The shader file itself is deployed as a hard link by modules/hm/path.nix, so
# editing the repo copy is enough; this script only flips the live option.

set -u

command -v hyprctl >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

shaders_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/shaders"
vibrance="$shaders_dir/self_vibrance.frag"
noop="$shaders_dir/disable.frag"
[ -e "$noop" ] || noop="[[EMPTY]]"

current="$(hyprctl -j getoption decoration:screen_shader 2>/dev/null | jq -r '.str // ""')"

case "$current" in
*self_vibrance*)
    hyprctl keyword decoration:screen_shader "$noop" >/dev/null 2>&1 || exit 1
    label="off"
    ;;
*)
    hyprctl keyword decoration:screen_shader "$vibrance" >/dev/null 2>&1 || exit 1
    label="on · vibrance"
    ;;
esac

notify-send -a "Screen shader" -i preferences-desktop-display "Screen shader" "$label" 2>/dev/null || true
