{ config, ... }:

let

  _flakeConfigDir = "${config.home.homeDirectory}/hydenix/modules/hm/config";
  hyprland_shadres = "${config.home.homeDirectory}/hydenix/modules/hm/config/shaders/self_vibrance.frag";
in
{
  # home.file.".claude/CLAUDE.md".source =
  #   config.lib.file.mkOutOfStoreSymlink "${flakeConfigDir}/claude/CLAUDE.md";
  xdg.configFile."hypr/shaders/self_vibrance.frag".source = config.lib.file.mkOutOfStoreSymlink "${
    hyprland_shadres
  }";
}
