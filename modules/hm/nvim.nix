{ config, pkgs, ... }:
let
  # Must point at the mutable working clone, not a store path: a Nix path
  # literal (`./config`) would be copied into /nix/store, and /nix is a separate
  # mount here, so hard links across it fail ("Invalid cross-device link").
  # Keep in sync with modules/hm/path.nix.
  flakeConfigDir = "/home/hydenix/hydenix-dotfiles/modules/hm/config";
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

      # nix Related
      statix
      nixfmt
    ];

  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${flakeConfigDir}/nvim";
}
