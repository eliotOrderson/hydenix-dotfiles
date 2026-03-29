{ config, ... }:

{
  hydenix.hm.xdg.enable = false;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    download = "${config.home.homeDirectory}/Downloads";
    pictures = "${config.home.homeDirectory}/Pictures";

    desktop = null;
    documents = null;
    music = null;
    publicShare = null;
    templates = null;
    videos = null;
  };
  xdg.configFile."user-dirs.conf".text = "enabled=False";
}
