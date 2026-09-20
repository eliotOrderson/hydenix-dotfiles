# This machine evaluates configuration.nix as the LAN cache and build server.
{ ... }:
{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  hydenix.hostname = "hydenix";
}
