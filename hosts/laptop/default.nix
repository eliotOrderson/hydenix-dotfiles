# This machine evaluates configuration.nix as the LAN cache and build client.
{ inputs, config, ... }:
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
}
