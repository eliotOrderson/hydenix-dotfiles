{ config, pkgs, ... }:
let
  flakeConfigDir = "${config.home.homeDirectory}/hydenix/modules/hm/config";
in
{
  hydenix.hm.editors = {
    enable = true;
    vscode = {
      enable = true;
      wallbash = true;
    };

    vim = false;
    neovim = false;
    default = "nvim";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      git
      gcc
      gnumake
      unzip
      wget
      curl

      ripgrep
      fd

      # nix Related
      statix
      nixfmt
    ];

  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${flakeConfigDir}/nvim";
}
