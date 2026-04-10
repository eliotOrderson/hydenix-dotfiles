{ pkgs, ... }:
{
  services.gammastep = {
    enable = true;
    latitude = "26.267"; # 填你所在城市的纬度
    longitude = "107.514"; # 填经度
    temperature = {
      day = 5500; # 白天强行锁定在 6500K（标准白色）
      night = 3500; # 晚上暖色护眼
    };
    settings = {
      general = {
        # 调节 Gamma 值，如果屏幕发灰，尝试调低到 0.8 或 0.9
        gamma = 0.85;
        brightness-day = 1.0;
      };
    };
  };

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
