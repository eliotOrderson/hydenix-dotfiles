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

      alias tar-zstd="tar -I 'zstd -T0' -cvf"
      alias untar-zstd="tar -I 'zstd -T0' -vxf"
      alias encrypt="age -e -p"
      alias decrypt="age -d"
    '';

  };
}
