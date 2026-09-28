{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.hydenix.hm.packages;
in
{
  # Host-toggleable packages. Each one is installed unless a host turns it off,
  # so a host that does not want it never evaluates or builds the package.
  options.hydenix.hm.packages.godot.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install Godot with the Wayland display driver forced.";
  };

  config = {
    home.packages = lib.optionals cfg.godot.enable [
      pkgs.unstable.godot
      # (pkgs.symlinkJoin {
      #   name = "godot4-wayland";
      #   paths = [ pkgs.unstable.godot ];
      #   buildInputs = [ pkgs.makeWrapper ];
      #   postBuild = ''
      #     wrapProgram $out/bin/godot4 \
      #       --add-flags "--display-driver wayland"
      #   '';
      # })
    ];
  };
}
