#!/usr/bin/env bash
# Print the NixOS configuration block for a fresh machine.
#
# Why this exists: a minimal NixOS install has no git, editor, shell or proxy,
# so this dotfiles repository cannot even be cloned yet. Paste the printed block
# into the top-level attribute set of /etc/nixos/configuration.nix, rebuild once,
# and the machine has clash-verge (TUN), git, neovim and fish.
#
# The block is meant to be copied by hand, so it only uses options that a fresh
# configuration.nix does not already define. The single exception is
# environment.systemPackages, which the installer template already defines; the
# block says so where it matters.
#
# Usage:
#   ./bootstrap-nixos.sh > block.nix    # stdout is the paste-ready block
#
# This targets a classic (non-flake) /etc/nixos setup, and needs a nixpkgs with
# the programs.clash-verge module. On a flake-managed machine put these settings
# in that flake instead.
set -euo pipefail

# Extra system-wide packages installed on top of the mandatory git/neovim.
# Values are nixpkgs attribute names, e.g.:
#   EXTRA_PACKAGES=(curl wget ripgrep fd fzf jq tree unzip htop)
EXTRA_PACKAGES=()

if [[ $# -gt 0 ]]; then
  echo "usage: $(basename -- "$0")   # prints the configuration block on stdout" >&2
  exit 2
fi

emit_block() {
  local pkg
  cat <<'NIX'
  # clash-verge-rev. TUN mode needs the core (verge-mihomo) running as root,
  # which serviceMode provides through the clash-verge.service unit; the
  # tunMode wrapper alone is not sufficient.
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev;
    serviceMode = true;
    tunMode = true;
    autoStart = false;
  };

  # The upstream module omits CAP_NET_BIND_SERVICE from the service bounding
  # set, so the core cannot bind its DNS listener on :53. List options merge by
  # concatenation, so this adds the capability instead of replacing the set.
  systemd.services.clash-verge.serviceConfig.CapabilityBoundingSet =
    [ "CAP_NET_BIND_SERVICE" ];

  networking.firewall.trustedInterfaces = [ "Mihomo" ];

  # NetworkManager hands out the DHCP gateway as the system DNS server. The TUN
  # core hijacks queries to that address but never answers them, so every lookup
  # stalls ~10s and then falls through to a poisoned answer. Static resolvers
  # are hijack-served (instant fake-ip) while TUN is up, and work as plain
  # direct DNS when it is off.
  networking.networkmanager.dns = "none";
  environment.etc."resolv.conf".text = ''
    nameserver 223.5.5.5
    nameserver 119.29.29.29
    options edns0
  '';

  # fish as the default login shell. An explicit per-user `shell = ...` wins
  # over users.defaultUserShell, so change that line by hand if one exists.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # A fresh configuration.nix already defines environment.systemPackages: merge
  # these entries into that list instead of pasting a second definition.
  environment.systemPackages = with pkgs; [
    git
    neovim
NIX
  for pkg in "${EXTRA_PACKAGES[@]}"; do
    printf '    %s\n' "$pkg"
  done
  cat <<'NIX'
  ];
NIX
}

emit_block

cat >&2 <<'TXT'

next:
  1. paste the block above into the top-level { ... } of /etc/nixos/configuration.nix
  2. sudo nixos-rebuild switch
  3. passwd
  4. re-login for fish (or run: exec fish)
  5. open clash-verge once and enable Service Mode and TUN mode in its settings
TXT
