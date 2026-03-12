{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "rtk";
  version = "v0.28.2";

  src = pkgs.fetchurl {
    # 请确保这是完整的下载链接
    url = "https://github.com/rtk-ai/rtk/releases/download/${version}/${pname}-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "c7b61e87b8430e42b04ab84fbe1b3b41b563454b0181247fd04844b8e9194371";
  };

  # musl 二进制通常不需要解压后再处理，直接把解压出来的文件装好即可
  # 如果压缩包里直接是二进制文件：
  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    # 假设压缩包解压后的二进制名字叫 rtk，如果不是请修改
    cp rtk $out/bin/
    chmod +x $out/bin/rtk
  '';

  meta = {
    description = "RTK binary (musl build) for NixOS";
    homepage = "https://github.com/rtk-ai/rtk";
  };
}
