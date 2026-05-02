{ pkgs, inputs, ... }:

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
      inputs.fcitx5-vinput.packages.${pkgs.system}.default
    ];
  };

  systemd.user.services.vinput-daemon = {
    Unit = {
      Description = "fcitx5-vinput daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${inputs.fcitx5-vinput.packages.${pkgs.system}.default}/bin/vinput-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
