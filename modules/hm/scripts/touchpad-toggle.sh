#!/usr/bin/env bash
# Toggle the laptop touchpad, bound to Super+M in hosts/laptop/default.nix.
#
# The touchpad is switched through Hyprland's per-device config: libinput has no
# runtime disable of its own here.
#
# Hyprland cannot report a device's `enabled` value back: `hyprctl devices` is
# identical either way and `hyprctl getoption` rejects device options. The state
# therefore lives in a marker file recording the last command, and anything that
# changes the device without going through this script - `hyprctl reload`, a
# Hyprland restart, a manual `hyprctl keyword` - makes that record stale, which
# silently inverts the next toggle. `reset` is the escape hatch for those cases:
# assert the default (enabled) and drop the record. It is run at Hyprland
# startup, where every device is enabled, and on Shift+Super+M by hand.

set -u

command -v hyprctl >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

state=/tmp/touchpad-toggle.disabled

case "${1:-toggle}" in
on | reset) # same action; `reset` names the intent of recovering from drift
    rm -f "$state"
    enabled=true
    ;;
off)
    : >"$state"
    enabled=false
    ;;
toggle)
    if [ -e "$state" ]; then
        rm -f "$state"
        enabled=true
    else
        : >"$state"
        enabled=false
    fi
    ;;
*)
    echo "usage: touchpad-toggle [toggle|on|off|reset]" >&2
    exit 1
    ;;
esac

# One physical touchpad exposes two pointer nodes, and which of them drives the
# cursor is firmware dependent, so both are switched.
hyprctl -j devices 2>/dev/null | jq -r '.mice[].name' | grep -i touchpad | while IFS= read -r name; do
    hyprctl keyword "device[$name]:enabled" "$enabled" >/dev/null 2>&1
    hyprctl keyword "device[${name%-touchpad}-mouse]:enabled" "$enabled" >/dev/null 2>&1
done

exit 0
