{ pkgs }:

let
  mkGitHubBin =
    {
      pname,
      version,
      url,
      sha256,
      binName ? pname,
    }:
    pkgs.stdenv.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl { inherit url sha256; };

      sourceRoot = ".";
      dontBuild = true;

      installPhase = ''
        mkdir -p $out/bin
        install -D -m755 ${binName} $out/bin/${pname}
      '';
    };

in
{
  # RTK 配置
  rtk = mkGitHubBin {
    pname = "rtk";
    version = "v0.28.2";
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.28.2/rtk-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "c7b61e87b8430e42b04ab84fbe1b3b41b563454b0181247fd04844b8e9194371";
  };

  # openlink = mkGitHubBin {
  #   pname = "openlink";
  #   version = "v0.0.9";
  #   url = "https://github.com/afumu/openlink/releases/download/v0.0.9/openlink_linux_amd64.tar.gz";
  #   sha256 = "2225e7d80c1a42952bb405a6226bec105e4ab2adb849083d909a542dfa24e45e";
  # };

}
