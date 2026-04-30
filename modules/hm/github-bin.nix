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
    pkgs.stdenv.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl { inherit url sha256; };

      sourceRoot = ".";
      dontBuild = true;
      nativeBuildInputs = [ pkgs.installShellFiles ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin

        if [ ! -f "${binName}" ]; then
          echo "===================================================="
          echo "ERROR: Binary '${binName}' not found in the source tree."
          echo "Current directory contents (recursive):"
          ls -R .
          echo "===================================================="
          exit 1
        fi

        install -D -m755 "${binName}" "$out/bin/${pname}"

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
    version = "0.11.7";
    url = "https://releases.astral.sh/github/uv/releases/download/${version}/uv-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "64ddb5f1087649e3f75aa50d139aa4f36ddde728a5295a141e0fa9697bfb7b0f";
    binName = "uv-x86_64-unknown-linux-musl/uv";
    postInstall = ''
      install -m755 uv-x86_64-unknown-linux-musl/uvx $out/bin/uvx

      $out/bin/${pname} --generate-shell-completion zsh > _uv
      installShellCompletion --zsh _uv
    '';
  };
}
