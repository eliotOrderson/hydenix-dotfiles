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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25; # 25%（estimate 7.5GiB）for zRAM
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # Warning when physical memory is at 5% remaining
    freeSwapThreshold = 5; # Kill when zRAM is at 5% remaining
  };
}
