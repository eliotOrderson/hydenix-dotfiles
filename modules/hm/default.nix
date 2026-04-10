{ pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./nvim.nix
    ./input-method.nix
    ./services.nix
    ./hyprland.nix
    ./theme.nix
    ./zsh.nix
    ./services.nix
    ./script.nix
    ./xdg.nix
    ./path.nix # manage config file hard link
    ./git.nix
  ];

  # home-manager options go here
  home.packages =
    let
      github-bin = import ./github-bin.nix { inherit pkgs; };
    in
    [
      pkgs.google-chrome
      pkgs.yazi
      pkgs.trash-cli
      pkgs.unstable.uv
      pkgs.unstable.bun
      pkgs.nodejs
      pkgs.zoxide
      pkgs.direnv
      pkgs.nix-init

      pkgs.unstable.claude-code-router
      pkgs.unstable.opencode
      pkgs.nix-search-cli
      pkgs.obsidian

      pkgs.gh # github cli
      github-bin.rtk

      # github-bin.openlink # extend ai web chat scaffold

      # rust dev tools
      # pkgs.cargo
      pkgs.rustup
      pkgs.clang
      pkgs.mold
      pkgs.sccache
    ];

  # Visit https://github.com/richen604/hydenix/blob/main/docs/options.md for more options
  hydenix = {
    hm = {

      # hydenix home-manager options go here
      enable = true;
      hyprland.hypridle.enable = false;
      lockscreen = {
        enable = false; # enable lockscreen module
        hyprlock = false; # enable hyprlock lockscreen
        swaylock = false; # enable swaylock lockscreen
      };
    };
  };

}
