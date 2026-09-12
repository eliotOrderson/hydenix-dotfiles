{ pkgs, ... }:
{
  # hardware-configuration.nix describes one machine: a stale device path builds
  # successfully and then hangs in stage 1 waiting for a device that is not there.
  # switch-to-configuration runs these fragments before it switches to a new
  # generation, so a mismatch aborts the rebuild instead of reaching the boot
  # loader; `switch-to-configuration check` runs only the checks.
  # The fragment receives the new configuration path as $1.
  #
  # The fragment runs with an empty environment, so the wrapper that nixpkgs
  # builds around it exposes PATH="$PATH" and nothing else. Listing the tools
  # here is what actually puts them on PATH for the check script.
  system.preSwitchChecks.hardwareConfiguration = ''
    ${pkgs.lib.getExe (pkgs.writeShellApplication {
      name = "check-filesystems";
      runtimeInputs = with pkgs; [
        bash
        coreutils
        gnugrep
        gnused
      ];
      text = ''
        exec ${pkgs.bash}/bin/bash ${../../scripts/check-filesystems.sh} "$@"
      '';
    })} "$1/etc/fstab"
  '';
}
