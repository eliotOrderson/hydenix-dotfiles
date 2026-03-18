{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    rootless.enable = false;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
    };
  };

  hardware.nvidia-container-toolkit.enable = true;
  users.users.hydenix.extraGroups = [ "docker" ];
}
