{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      # theme
      fcitx5-nord
      fcitx5-fluent

      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-wanxiang
        ];
      })
    ];
  };

}
