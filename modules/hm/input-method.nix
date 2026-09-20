{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  cfg = config.hydenix.hm.inputMethod.voiceInput;
in
{
  options.hydenix.hm.inputMethod.voiceInput.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable fcitx5-vinput voice input.";
  };

  config = {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.addons =
        with pkgs;
        [
          # theme
          fcitx5-nord
          fcitx5-fluent

          (fcitx5-rime.override {
            rimeDataPkgs = [
              pkgs.unstable.rime-wanxiang
            ];
          })
        ]
        ++ lib.optionals cfg.enable [
          # voices input
          inputs.fcitx5-vinput.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
    };

    systemd.user.services.vinput-daemon = lib.mkIf cfg.enable {
      Unit = {
        Description = "fcitx5-vinput daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${
          inputs.fcitx5-vinput.packages.${pkgs.stdenv.hostPlatform.system}.default
        }/bin/vinput-daemon";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
