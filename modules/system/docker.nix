{
  virtualisation.docker = {
    enable = true;
    rootless.enable = false;
  };

  hardware.nvidia-container-toolkit.enable = true;
  users.users.hydenix.extraGroups = [ "docker" ];
}
