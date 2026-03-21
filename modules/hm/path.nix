{ config, ... }:

let

  _flakeConfigDir = "${config.home.homeDirectory}/hydenix/modules/hm/config";
in
{
  # home.file.".claude/CLAUDE.md".source =
  #   config.lib.file.mkOutOfStoreSymlink "${flakeConfigDir}/claude/CLAUDE.md";
}
