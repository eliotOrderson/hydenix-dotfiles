# This machine evaluates configuration.nix as the LAN cache and build server.
{ inputs, ... }:
{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix

    # Hardware profile: AMD CPU (Ryzen 7 9700X), NVIDIA GPU, NVMe SSD.
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  hydenix.hostname = "hydenix";
}
