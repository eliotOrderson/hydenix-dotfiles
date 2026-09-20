# This machine evaluates configuration.nix as the LAN cache and build client.
{ inputs, ... }:
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

  hydenix.hostname = "hydenix-laptop";
}
