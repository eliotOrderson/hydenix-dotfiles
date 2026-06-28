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

}
