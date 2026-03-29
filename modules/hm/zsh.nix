{ pkgs, ... }:
{

  programs.zsh = {

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];

    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.config/zsh/.zsh_history";
      share = true; # Equivalent to SHARE_HISTORY
      extended = true; # Equivalent to EXTENDED_HISTORY
      ignoreDups = true; # Equivalent to HIST_IGNORE_DUPS
      ignoreAllDups = true; # Equivalent to HIST_IGNORE_ALL_DUPS
      ignoreSpace = true; # Equivalent to HIST_IGNORE_SPACE
    };

  };

  hydenix.hm.shell.zsh = {
    plugins = [
      "sudo"
    ];

    configText = ''
      setopt CORRECT
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
      export PATH=$PATH:~/.npm-global/bin

      function lf() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
      }

      unlock-git() {
          echo "⚠️ Remote operation detected. Mem Key is being automatically unlocked..."
          export SOPS_AGE_KEY=$(sudo nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key)
          [ -z "$SSH_AUTH_SOCK" ] && eval $(ssh-agent -s) > /dev/null
          nix run nixpkgs#sops -- -d --extract '["github_private_key"]' ~/hydenix/modules/system/config/secrets.yaml | ssh-add - 2>/dev/null
          unset SOPS_AGE_KEY
     }

      git() {
          if [[ " push pull fetch clone " =~ " $1 " ]]; then
          ssh-add -l >/dev/null 2>&1 || unlock-git || return 1
          fi
          command git "$@"
      }

      alias tar-zstd="tar -I 'zstd -T0' -cvf"
      alias untar-zstd="tar -I 'zstd -T0' -vxf"
      alias encrypt="age -e -p"
      alias decrypt="age -d"
    '';

  };
}
