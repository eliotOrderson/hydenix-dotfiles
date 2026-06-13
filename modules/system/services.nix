{ pkgs, ... }:
{
  networking.firewall = {
    trustedInterfaces = [
      "Mihomo"
    ];
  };

  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
  };

  services = {
    flatpak.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "hydenix";
    };
    displayManager.defaultSession = "hyprland-uwsm";
  };

}
