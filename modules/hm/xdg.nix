{ config, ... }:

{
  hydenix.hm.xdg.enable = true;

  # xdg.portal.xdgOpenUsePortal only changes how the host xdg-open command
  # dispatches: it forwards to org.freedesktop.portal.OpenURI instead of
  # resolving a handler itself. The portal frontend still resolves standard mime
  # types through mimeapps.list, but it rejects custom x-scheme-handler entries
  # and xdg-open reports success regardless. Nothing here consumes the
  # file-descriptor semantics that the portal path exists for: no flatpak app is
  # installed and no script or HyDE helper calls xdg-open. Keep the direct path.
  xdg.portal.xdgOpenUsePortal = false;

  # Upstream only maps inode/directory, x-scheme-handler/file and
  # x-scheme-handler/about (dolphin.nix), so browsers and the clash schemes
  # still need a downstream entry.
  xdg.mimeApps = {
    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };

    associations.added = {
      "x-scheme-handler/clash" = [ "clash-verge.desktop" ];
      "x-scheme-handler/clash-verge" = [ "clash-verge.desktop" ];
    };
  };

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
