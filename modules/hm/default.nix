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
      pkgs.zoxide
      pkgs.direnv
      pkgs.nix-init
      pkgs.nix-search-cli
      pkgs.obsidian
      pkgs.gh # github cli
      pkgs.git-lfs
      pkgs.wireguard-tools

      # base cli
      pkgs.unzip
      pkgs.wget
      pkgs.ripgrep
      pkgs.fd
      pkgs.tree
      pkgs.mdcat
      pkgs.defuddle-cli

      # improves some bash-output compression paths
      pkgs.shellcheck
      pkgs.yq
      pkgs.scc

      # github release
      github-bin.rtk
      github-bin.uv

      # python
      # pkgs.python313Packages.mempalace

      # unstable
      pkgs.unstable.zed-editor-fhs
      pkgs.unstable.nodejs
      pkgs.unstable.pnpm

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
      dolphin.enable = true;
      hyprland.hypridle.enable = false;
      lockscreen = {
        enable = false; # enable lockscreen module
        hyprlock = false; # enable hyprlock lockscreen
        swaylock = false; # enable swaylock lockscreen
      };
    };
  };

}
