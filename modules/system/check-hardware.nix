{ pkgs, ... }:
{
  # hardware-configuration.nix describes one machine: a stale device path builds
  # successfully and then hangs in stage 1 waiting for a device that is not there.
  # switch-to-configuration runs these fragments before it switches to a new
  # generation, so a mismatch aborts the rebuild instead of reaching the boot
  # loader; `switch-to-configuration check` runs only the checks.
  # The fragment receives the new configuration path as $1.
  system.preSwitchChecks.hardwareConfiguration = ''
    ${pkgs.bash}/bin/bash ${../../scripts/check-filesystems.sh} "$1/etc/fstab"
  '';
}
