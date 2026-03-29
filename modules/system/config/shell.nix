{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  nativeBuildInputs = [ 
    pkgs.ssh-to-age 
    pkgs.sops
  ];

  shellHook = ''
    # 现在 shellHook 运行时，ssh-to-age 已经在 PATH 里的，可以直接调用
    export SOPS_AGE_KEY=$(sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key)
    echo "--------------------------------------------------"
    echo "🔒 Secrets environment ready. (Key is in memory only)"
    echo "🛠️ Tools loaded: ssh-to-age, sops"
    echo "--------------------------------------------------"
  '';
}
