# This machine evaluates configuration.nix as the LAN cache and build client.
{ ... }:
{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  hydenix.hostname = "hydenix-laptop";
}
