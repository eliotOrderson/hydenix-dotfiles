{ pkgs, ... }:

{
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    stdenv.cc.cc.lib  # libstdc++ for numpy/chroma-mcp
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    libglvnd
    glib
  ];
}
