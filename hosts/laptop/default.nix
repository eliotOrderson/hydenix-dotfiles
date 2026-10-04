# This machine evaluates configuration.nix as the LAN cache and build client.
{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix

    # Hardware profile: Intel CPU (i5-8265U) with its UHD 620 driving the panel,
    # NVIDIA MX250 alongside it, NVMe SSD.
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # R580 is the last driver branch for Pascal (MX250). Prefer the frozen legacy
  # branch once nixpkgs ships it; stable is still 580 on the current pin.
  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.legacy_580
      or config.boot.kernelPackages.nvidiaPackages.stable;

  hydenix.hostname = "hydenix-laptop";

  # Voice input is only wanted on the desktop; the module defaults to enabled.
  home-manager.users.hydenix.hydenix.hm.inputMethod.voiceInput.enable = false;

  # Godot is only wanted on the desktop; the module defaults to enabled.
  home-manager.users.hydenix.hydenix.hm.packages.godot.enable = false;

  home-manager.users.hydenix.home.packages = [
    (pkgs.writeShellScriptBin "touchpad-toggle" (
      builtins.readFile ../../modules/hm/scripts/touchpad-toggle.sh
    ))
  ];

  # Super+M toggles the touchpad; Shift+Super+M resets the marker file when the
  # toggle state has drifted from the compositor.
  home-manager.users.hydenix.hydenix.hm.hyprland.extraConfig = ''
    bind = $mainMod, M, exec, touchpad-toggle
    bind = $mainMod SHIFT, M, exec, touchpad-toggle reset
    exec-once = touchpad-toggle reset
  '';
}
