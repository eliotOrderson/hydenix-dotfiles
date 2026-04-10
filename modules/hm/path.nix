{ config, ... }:

let

  hyprland_shadres = "${config.home.homeDirectory}/hydenix/modules/hm/config/shaders/self_vibrance.frag";
  zed_config = "${config.home.homeDirectory}/hydenix/modules/hm/config/zed";

in
{
  xdg.configFile."hypr/shaders/self_vibrance.frag".source = config.lib.file.mkOutOfStoreSymlink "${
    hyprland_shadres
  }";

  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${zed_config}";
}
