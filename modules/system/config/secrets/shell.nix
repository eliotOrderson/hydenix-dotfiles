{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.ssh-to-age
    pkgs.sops
  ];

  shellHook = ''
    export SOPS_AGE_KEY=$(sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key)
    echo "--------------------------------------------------"
    echo "🔒 Secrets environment ready. (Key is in memory only)"
    echo "🛠️ Tools loaded: ssh-to-age, sops"
    echo "--------------------------------------------------"
  '';
}
