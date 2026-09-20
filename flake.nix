{
  description = "template for hydenix";

  inputs = {
    nixpkgs = {
      # url = "github:nixos/nixpkgs/nixos-unstable"; # uncomment this if you know what you're doing
      follows = "hydenix/nixpkgs"; # then comment this
      # url = "github:nixos/nixpkgs/nixos-26.05"; unlock hydenix software
    };

    # Pinned to this fork's GitHub revision: it pins the Bibata cursor URL to the
    # HyDE rev and repairs dead theme sources (see eliotOrderson/hydenix). Fetched
    # from GitHub so a fresh clone builds on another machine without a local checkout.
    # Switch back to github:richen604/hydenix once those fixes land upstream.
    hydenix.url = "github:eliotOrderson/hydenix";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    fcitx5-vinput.url = "github:xifan2333/fcitx5-vinput";
    fcitx5-vinput.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      appPkgs = inputs.nixpkgs.legacyPackages.${system};

      # Every machine evaluates the same configuration.nix; the attribute name
      # selects the host directory (hostname + hardware-configuration.nix) that
      # goes with it. Nothing tracked differs between the machines' checkouts,
      # so both can pull the same history without merging each other's hardware.
      mkHost =
        role:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs role;
          };
          modules = [
            ./hosts/${role}
            #  using pkg.unsatable on home manger or system
            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit (prev.stdenv.hostPlatform) system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }
          ];
        };
      hostConfigs = {
        desktop = mkHost "desktop";
        laptop = mkHost "laptop";
      };
      vmConfig = inputs.hydenix.lib.vmConfig {
        inherit inputs;
        nixosConfiguration = hostConfigs.desktop;
      };
    in
    {
      nixosConfigurations = hostConfigs;
      packages."${system}".vm = vmConfig.config.system.build.vm;

      # Verify that the filesystems this configuration declares actually exist on
      # THIS machine, BEFORE building/rebooting. NixOS bakes device paths into the
      # initrd without validating them, so a hardware-configuration.nix from
      # another machine (or an older disk layout) builds fine and then hangs in
      # stage 1 waiting for a device that is not there.
      #
      #   nix run .#check-fs
      #   nix run .#check-fs -- /nix/var/nix/profiles/system/etc/fstab
      apps."${system}".check-fs = {
        type = "app";
        program = "${appPkgs.writeShellScript "check-fs" ''
          export CHECK_FS_HOSTS=${./hosts}
          exec ${appPkgs.bash}/bin/bash ${./scripts/check-filesystems.sh} "$@"
        ''}";
      };
    };
}
