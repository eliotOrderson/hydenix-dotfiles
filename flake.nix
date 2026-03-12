{
  description = "template for hydenix";

  inputs = {
    nixpkgs = {
      # url = "github:nixos/nixpkgs/nixos-unstable"; # uncomment this if you know what you're doing
      follows = "hydenix/nixpkgs"; # then comment this
    };

    hydenix.url = "github:richen604/hydenix";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      hydenixConfig = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
          #  using pkg.unsatable.xxx on home manger or system
          {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              })
            ];
          }
        ];
      };
      vmConfig = inputs.hydenix.lib.vmConfig {
        inherit inputs;
        nixosConfiguration = hydenixConfig;
      };
    in
    {
      nixosConfigurations.hydenix = hydenixConfig;
      nixosConfigurations.default = hydenixConfig;
      packages."x86_64-linux".vm = vmConfig.config.system.build.vm;
    };
}
