# Preflight check: verify that the filesystems a NixOS system will boot from
# actually exist on THIS machine.
#
# Why this exists: NixOS never validates device paths at build time. It bakes
# the string from hardware-configuration.nix straight into the initrd, so a
# config copied from another machine (or a disk that was reformatted) produces a
# *successful* build and then hangs at boot with:
#
#   Timed out waiting for device /dev/disk/by-uuid/<uuid> to appear
#   mount: /mnt-root: special device /dev/disk/by-uuid/<uuid> does not exist
#
# Run it BEFORE rebooting into a freshly built generation.
#
# Usage:
#   check-fs                                  # check hardware-configuration.nix
#   check-fs /nix/var/nix/profiles/system/etc/fstab
#   check-fs /nix/store/<gen>-nixos-system-*/ # or a generation directory
#
# Exit 0 = every declared device resolves on this machine.
set -euo pipefail

selfDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
flakeRoot=$(dirname -- "$selfDir")

if [[ $# -gt 0 ]]; then
  target=$1
elif [[ -r $flakeRoot/hardware-configuration.nix ]]; then
  # invoked directly from a checkout (not via `nix run`)
  target=$flakeRoot/hardware-configuration.nix
else
  target=$PWD/hardware-configuration.nix
fi

if [[ -d $target ]]; then
  target=$target/etc/fstab
fi

if [[ ! -r $target ]]; then
  echo "error: cannot read '$target'" >&2
  echo "usage: check-fs [path-to-fstab | path-to-hardware-configuration.nix | generation-dir]" >&2
  exit 2
fi

missing=()
count=0

# Verify one device reference; append to `missing` when it does not resolve.
check_device() {
  local device=$1 where=$2 ref
  case $device in
    /dev/disk/by-uuid/*)
      ref=${device##*/}
      # /dev/disk/by-uuid is lowercase; configs sometimes use uppercase.
      { [[ -e /dev/disk/by-uuid/${ref,,} ]] || [[ -e /dev/disk/by-uuid/$ref ]]; } \
        || missing+=("$where -> $device")
      ;;
    /dev/disk/by-partuuid/*)
      ref=${device##*/}
      { [[ -e /dev/disk/by-partuuid/${ref,,} ]] || [[ -e /dev/disk/by-partuuid/$ref ]]; } \
        || missing+=("$where -> $device")
      ;;
    /dev/disk/by-label/*)
      ref=${device##*/}
      [[ -e /dev/disk/by-label/$ref ]] || missing+=("$where -> $device")
      ;;
    *)
      [[ -e $device ]] || missing+=("$where -> $device")
      ;;
  esac
}

if [[ $target == *.nix ]]; then
  # hardware-configuration.nix: pair each `device = "/dev/..."` with the fsType
  # of the surrounding block so the report can name the filesystem.
  mapfile -t devices < <(grep -oE 'device[[:space:]]*=[[:space:]]*"/dev/[^"]+"' "$target" \
    | sed -E 's/.*"(\/dev\/[^"]+)".*/\1/')
  mapfile -t fstypes < <(grep -oE 'fsType[[:space:]]*=[[:space:]]*"[^"]+"' "$target" \
    | sed -E 's/.*"([^"]+)".*/\1/')
  for i in "${!devices[@]}"; do
    count=$((count + 1))
    check_device "${devices[$i]}" "${fstypes[$i]:-filesystem}"
  done
else
  while read -r device mountpoint fstype _rest; do
    # Only lines that clearly declare a filesystem; this skips nix's synthetic
    # entries (envfs, none, /usr/bin binds, comments).
    [[ $device == /dev/* ]] || continue
    count=$((count + 1))
    check_device "$device" "$mountpoint ($fstype)"
  done < "$target"
fi

if (( count == 0 )); then
  echo "warning: no /dev/... filesystem declarations found in $target" >&2
  echo "         (is this the right file? expected hardware-configuration.nix)" >&2
  exit 2
fi

if (( ${#missing[@]} > 0 )); then
  echo "error: $target declares devices that do NOT exist on this machine:" >&2
  echo >&2
  for m in "${missing[@]}"; do
    echo "  MISSING  $m" >&2
  done
  echo >&2
  echo "This system would build successfully and then FAIL TO BOOT in stage 1." >&2
  echo >&2
  echo "Almost always this means hardware-configuration.nix belongs to a different" >&2
  echo "machine or an older disk layout. Regenerate it here, then rebuild:" >&2
  echo >&2
  echo "  sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix" >&2
  echo "  sudo nixos-rebuild boot --flake .#hydenix" >&2
  echo >&2
  echo "Devices currently present on this machine:" >&2
  for dir in /dev/disk/by-uuid /dev/disk/by-label /dev/disk/by-partuuid; do
    [[ -d $dir ]] || continue
    echo "  $dir:" >&2
    ls -1 "$dir" 2>/dev/null | sed 's/^/    /' >&2 || true
  done
  exit 1
fi

echo "ok: all $count declared device(s) in $target exist on this machine"
