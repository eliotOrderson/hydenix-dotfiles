{ pkgs, ... }:
{
  services = {
    envfs.enable = true;

    flatpak.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "hydenix";
    };
    displayManager.defaultSession = "hyprland-uwsm";

    earlyoom = {
      enable = true;
      freeMemThreshold = 5; # Warning when physical memory is at 5% remaining
      freeSwapThreshold = 5; # Kill when zRAM is at 5% remaining
    };
  };

  networking.firewall = {
    trustedInterfaces = [
      "Mihomo"
    ];
  };

  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/clash-verge \
          --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
          --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      '';
    });
    serviceMode = true;
    tunMode = true;
    autoStart = true;
  };
  # The upstream module's service unit omits CAP_NET_BIND_SERVICE from its
  # bounding set, so the core cannot bind its DNS listener on port 53
  # ("listen :53: bind: permission denied" in the core log). Merge the missing
  # capability back in (list values are concatenated by the module system).
  systemd.services.clash-verge.serviceConfig.CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25; # 25%（estimate 7.5GiB）for zRAM
  };
}
