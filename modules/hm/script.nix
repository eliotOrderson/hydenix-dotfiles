{ pkgs, ... }:

let
  windows-control = pkgs.writeShellScriptBin "windows-control" (
    builtins.readFile ./scripts/windowoperation.sh
  );
  shader-toggle = pkgs.writeShellScriptBin "shader-toggle" (
    builtins.readFile ./scripts/shader-toggle.sh
  );
in
{
  home.packages = [
    windows-control
    shader-toggle
  ];
}
