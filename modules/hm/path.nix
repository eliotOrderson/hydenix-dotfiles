{ config, ... }:

# Restore repo configs via hard links on every rebuild.
# Hard links survive apps that reject symlinked config dirs.
# Directories an app rewrites itself get a symlink instead: see linkDir.
#
# NOTE: cfg must point at the *mutable working clone*, not a store path.
# A Nix path literal (e.g. `./config`) is copied into /nix/store, and /nix is a
# separate mount on this machine, so `ln` would fail with "Invalid cross-device
# link" — hard links cannot cross filesystems. Keep this path in sync with the
# checkout location and with modules/hm/nvim.nix.
let
  home = config.home.homeDirectory;
  cfg = "/home/hydenix/hydenix-dotfiles/modules/hm/config";

  restoreFile = src: dst: ''
    if [ -e '${src}' ]; then
      mkdir -p "$(dirname '${dst}')"
      ln -f '${src}' '${dst}'
    fi
  '';

  # Link every file under src into dst, skipping log files.
  restoreDir = src: dst: ''
    if [ -d '${src}' ]; then
      while IFS= read -r f; do
        rel="''${f#'${src}'}"
        mkdir -p "${dst}/$(dirname "$rel")"
        ln -f "$f" "${dst}/$rel"
      done < <(find '${src}' -type f ! -name '*.log')
    fi
  '';

  # Symlink dst at src so config writes land in the working clone.
  # Needed for apps that save with write-to-temp + rename (fcitx5's
  # StandardPaths::safeSave does): the rename replaces the inode and silently
  # breaks a hard link, leaving the repo copy stale and invisible to git.
  # Any existing dst is owned by us, so it is discarded like restoreDir does.
  linkDir = src: dst: ''
    if [ -d '${src}' ] && [ ! -L '${dst}' ]; then
      rm -rf '${dst}'
      mkdir -p "$(dirname '${dst}')"
      ln -sfn '${src}' '${dst}'
    fi
  '';
in
{
  home.activation.restoreConfigs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ${restoreFile "${cfg}/shaders/self_vibrance.frag" "${home}/.config/hypr/shaders/self_vibrance.frag"}
    ${restoreFile "${cfg}/npm/npmrc" "${home}/.npmrc"}
    ${restoreDir "${cfg}/zed" "${home}/.config/zed"}
    ${linkDir "${cfg}/fcitx5/fcitx5" "${home}/.config/fcitx5"}
    ${restoreDir "${cfg}/fcitx5/rime" "${home}/.local/share/fcitx5/rime"}
  '';
}
