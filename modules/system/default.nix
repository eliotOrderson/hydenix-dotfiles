{ pkgs, ... }:
{
  imports = [
    ./openrgb-gigabyteb850m.nix
    ./services.nix
    # ./sops.nix
    ./nix-ld.nix
    ./docker.nix
  ];

  hydenix.hardware.openrgb.GigbyteB850.enable = false;

  environment.systemPackages = [
    pkgs.clash-verge-rev
    pkgs.librime-lua
    pkgs.librime-octagram
    pkgs.sops
    pkgs.docker-compose
  ];

}
