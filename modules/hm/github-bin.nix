{ pkgs }:

let
  mkGitHubBin =
    {
      pname,
      version,
      url,
      sha256,
      binName ? pname,
      postInstall ? "",
    }:
    let
      # Evaluate whether it's an archive at Nix evaluation time.
      # This is much safer than relying on Bash to check the Nix store path later.
      isArchive =
        pkgs.lib.hasSuffix ".tar.gz" url
        || pkgs.lib.hasSuffix ".tgz" url
        || pkgs.lib.hasSuffix ".zip" url
        || pkgs.lib.hasSuffix ".tar.xz" url;
    in
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;

      # Only set the 'name' attribute if it's NOT an archive.
      # If it is an archive, we let fetchurl handle the name naturally.
      src = pkgs.fetchurl (
        { inherit url sha256; } // pkgs.lib.optionalAttrs (!isArchive) { name = binName; }
      );

      # Use the Nix boolean to dictate the Bash logic directly
      unpackPhase = ''
        runHook preUnpack

        ${
          if isArchive then
            ''
              # Archive: use the standard Nix unpacker
              unpackFile "$src"
            ''
          else
            ''
              # Single binary file: copy it to the build directory
              cp "$src" "./${binName}"
            ''
        }

        runHook postUnpack
      '';

      sourceRoot = ".";
      dontBuild = true;
      nativeBuildInputs = [ pkgs.installShellFiles ];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/bin"

        # Locate the binary file by its basename.
        BIN_PATH=$(find . -type f -name "${binName}" -print -quit)

        if [ -z "$BIN_PATH" ]; then
          echo "===================================================="
          echo "ERROR: Binary '${binName}' not found."
          echo "Current directory contents:"
          ls -R .
          echo "===================================================="
          exit 1
        fi

        # Install the binary, making it executable (755) and renaming it to $pname
        install -D -m755 "$BIN_PATH" "$out/bin/${pname}"

        ${postInstall}

        runHook postInstall
      '';
    };
in

{
  # musl replace glibc
  rtk = mkGitHubBin rec {
    pname = "rtk";
    version = "v0.34.3";
    url = "https://github.com/rtk-ai/rtk/releases/download/${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "a607c17bfdccc1d48dc94ca81cd3a545523329df6a378368fd175d8023425ea5";
  };

  uv = mkGitHubBin rec {
    pname = "uv";
    version = "0.11.21";
    url = "https://releases.astral.sh/github/uv/releases/download/${version}/uv-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "9dadff5b9e7b1d2d011e41852a1cbca713d9d5d88194f2eb6bd240fa4fb0a719";

    # CHANGED: 'find -name' searches by basename, so it just needs to be "uv".
    # It will successfully find it inside the extracted uv-x86_64... directory.
    binName = "uv";

    postInstall = ''
      install -m755 uv-x86_64-unknown-linux-musl/uvx $out/bin/uvx

      $out/bin/${pname} --generate-shell-completion zsh > _uv
      installShellCompletion --zsh _uv
    '';
  };
}
