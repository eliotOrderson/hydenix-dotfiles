{ config, ... }:

# Restore repo configs via hard links on every rebuild.
# Hard links survive apps that reject symlinked config dirs.
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
in
{
  home.activation.restoreConfigs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ${restoreFile "${cfg}/shaders/self_vibrance.frag" "${home}/.config/hypr/shaders/self_vibrance.frag"}
    ${restoreFile "${cfg}/npm/npmrc" "${home}/.npmrc"}
    ${restoreDir "${cfg}/zed" "${home}/.config/zed"}
    ${restoreDir "${cfg}/fcitx5" "${home}/.local/share/fcitx5/rime"}
  '';
}
