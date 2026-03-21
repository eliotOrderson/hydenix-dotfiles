{ pkgs, ... }:
{

  services.flatpak.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "hydenix";
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  systemd.services.clash-verge-service = {
    description = "Auto start service ...";
    wantedBy = [ "multi-user.target" ]; # boot startup
    after = [ "network.target" ]; # Start after the network is ready
    serviceConfig = {
      ExecStart = "${pkgs.clash-verge-rev}/bin/clash-verge-service";
      Restart = "always";
      User = "root";
    };
  };

}
