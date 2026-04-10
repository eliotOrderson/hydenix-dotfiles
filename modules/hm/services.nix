{ pkgs, ... }:
{
  # autostart on boot start clash ui
  systemd.user.services.clash-verge = {
    Unit = {
      Description = "Clash Verge Rev Service";
      After = [ "graphical-session.target" ];
      Partof = [ "graphical-session.target" ];
    };

    Service = {
      Environment = "GDK_BACKEND=x11 WEBKIT_DISABLE_DMABUF_RENDERER=1 WEBKIT_DISABLE_COMPOSITION_MODE=1";
      ExecStart = "${pkgs.clash-verge-rev}/bin/clash-verge";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
