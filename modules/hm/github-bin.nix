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
  rtk = mkGitHubBin rec {
    pname = "rtk";
    version = "v0.34.3";
    url = "https://github.com/rtk-ai/rtk/releases/download/${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "a607c17bfdccc1d48dc94ca81cd3a545523329df6a378368fd175d8023425ea5";
  };

  cc-switch-cli = mkGitHubBin rec {
    pname = "cc-switch";
    version = "v5.1.1";
    url = "https://github.com/SaladDay/cc-switch-cli/releases/download/${version}/cc-switch-cli-linux-x64-musl.tar.gz";
    sha256 = "e2389e8cd9bda494f646d1ddf6fc5d2703094750c796ad412f0e36cae00c5440";
  };

  # cli-proxy-api = mkGitHubBin {
  #   pname = "cli-proxy-api";
  #   version = "v6.8.55";
  #   url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v6.8.55/CLIProxyAPI_6.8.55_linux_amd64.tar.gz";
  #   sha256 = "sha256:b818c3d69e087cb4ff6aa75147f00bb096944a10780ece7fd159191d55404009";
  #   postInstall = ''
  #     mkdir -p $out/etc/cli-proxy-api
  #     [ -f config.example.yaml ] && cp config.example.yaml $out/etc/cli-proxy-api/config.yaml
  #     # if software require binary and config together
  #     # ln -s $out/etc/cli-proxy-api/config.yaml $out/bin/config.yaml
  #   '';
  # };

}
