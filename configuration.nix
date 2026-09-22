{
  inputs,
  pkgs,
  config,
  lib,
  role,
  ...
}:
# FOLLOW THE BELOW INSTRUCTIONS LINE BY LINE TO SET UP YOUR SYSTEM
let
  # flake.nix picks the role per machine, so this file is identical on every
  # host and merges cleanly over git. "desktop" serves the LAN cache and builds
  # for the others; "laptop" substitutes from it and sends its builds there.
  isServer = role == "desktop";

  # Everything that identifies the desktop on the LAN. The same address ends up
  # in the substituter URL, the build machine, the known_hosts entry and the
  # cache listener, so declaring it once keeps those four from drifting apart.
  lanCache = {
    host = "192.168.31.25";
    port = 5000;
    # Public half of the key services.nix-serve signs exported paths with.
    publicKey = "hydenix-lan-cache:IRGysUzotiMc6pfsd6JlOc7Zm21U1HRB3c94i5yc8L8=";
    # The desktop's SSH host key, which the clients have to know in advance.
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5M1h2IkraDVqZ4SxkaCnDnvkcL0+7PVKtQCVyREZBE";
  };
in
{
  imports = [
    # hydenix inputs - Required modules, don't modify unless you know what you're doing
    inputs.hydenix.inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.nixosModules.default
    # Decrypts ./modules/system/config/secrets/* with this host's SSH key.
    inputs.sops-nix.nixosModules.sops
    ./modules/system # Your custom system modules

    # Hardware modules (GPU/CPU/disk) are per machine and live in hosts/<role>,
    # otherwise every host inherits one machine's CPU and GPU drivers.
  ];

  # If enabling NVIDIA, you will be prompted to configure hardware.nvidia
  hardware.nvidia = {
    open = false; # For newer cards, you may want open drivers
    prime.sync.enable = false;
    prime.offload.enable = false;

    nvidiaSettings = true;
    modesetting.enable = true;
    #   prime = { # For hybrid graphics (laptops), configure PRIME:
    #     amdBusId = "PCI:0:2:0"; # Run `lspci | grep VGA` to get correct bus IDs
    #     intelBusId = "PCI:0:2:0"; # if you have intel graphics
    #     nvidiaBusId = "PCI:1:0:0";
    #     offload.enable = false; # Or disable PRIME offloading if you don't care
    #   };
  };

  # Home Manager Configuration - manages user-specific configurations (dotfiles, themes, etc.)
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # User Configuration - REQUIRED: Change "hydenix" to your actual username
    # This must match the username you define in users.users below
    users."hydenix" =
      { ... }:
      {
        imports = [
          inputs.hydenix.homeModules.default
          ./modules/hm # Your custom home-manager modules (configure hydenix.hm here!)
        ];
      };
  };

  # User Account Setup - REQUIRED: Change "hydenix" to your desired username (must match above)
  users.users.hydenix = {
    isNormalUser = true;
    initialPassword = "shijie"; # SECURITY: Change this password after first login with `passwd`
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ]; # User groups (determines permissions)
    shell = pkgs.zsh; # Default shell (options: pkgs.bash, pkgs.zsh, pkgs.fish)
    # The laptop's nix-daemon logs in here to run the builds listed in its
    # nix.buildMachines.
    openssh.authorizedKeys.keys = lib.mkIf isServer [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkeDvwZiaOYB+UNSG2le6uc6VyeU7b3eeewO1jMBhOo nix-builder-laptop"
    ];
  };

  # Hydenix Configuration - Main configuration for the Hydenix desktop environment
  # (hydenix.hostname lives in the host directory: it is the one setting that
  # differs per machine.)
  hydenix = {
    enable = true; # Enable Hydenix modules
    # Basic System Settings (REQUIRED):
    timezone = "Asia/Shanghai"; # REQUIRED: Set timezone (examples: "America/New_York", "Europe/London", "Asia/Tokyo")
    locale = "en_US.UTF-8"; # REQUIRED: Set locale/language (examples: "en_US.UTF-8", "en_GB.UTF-8", "de_DE.UTF-8")
    # For more configuration options, see: ./docs/options.md
  };

  # NetworkManager hands out the DHCP gateway as the system DNS server. The
  # TUN core hijacks queries to that address but never answers them (mihomo
  # quirk with the default-gateway address), so every lookup stalls ~10s and
  # then falls through to a GFW-poisoned IPv6 answer. Use static resolvers
  # instead: when TUN is up they are hijack-served by the core (instant
  # fake-ip, correct per-domain routing); when TUN is off they work as plain
  # direct DNS.
  networking.networkmanager.dns = "none";
  environment.etc."resolv.conf".text = ''
    nameserver 223.5.5.5
    nameserver 119.29.29.29
    options edns0
  '';

  # crates.io's /api/v1 download endpoint is behind Cloudflare bot-protection
  # that 403s nix's fetcher (curl's TLS fingerprint), while the CDN host
  # static.crates.io serves the identical .crate files without the check.
  # Rewrite the URLs in the generic fetcher so every crate fetch works.
  nixpkgs.overlays = [
    (final: prev: {
      fetchurl =
        args:
        let
          rewrite =
            u:
            let
              m = builtins.match "https://crates.io/api/v1/crates/([^/]+)/([^/]+)/download" u;
            in
            if m == null then
              u
            else
              "https://static.crates.io/crates/${builtins.head m}/${builtins.head m}-${builtins.elemAt m 1}.crate";
        in
        prev.fetchurl (
          if args ? urls then
            args // { urls = map rewrite args.urls; }
          else if args ? url then
            args // { url = rewrite args.url; }
          else
            args
        );
    })
  ];
  nix = {
    settings = {
      auto-optimise-store = true;
      # On the client the LAN cache has to come first, otherwise a hit on the
      # desktop's store loses to a slower download from the internet mirrors.
      substituters =
        lib.optionals (!isServer) [ "http://${lanCache.host}:${toString lanCache.port}" ]
        ++ [
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
      # The mirrors above can accept the connection and then stop sending data;
      # the 300s default leaves nix sitting on a dead transfer instead of
      # falling through to the next substituter.
      stalled-download-timeout = 15;
    }
    // lib.optionalAttrs isServer {
      # The client's remote builds connect as this user and have to be allowed
      # to add their results to this store.
      trusted-users = [ "hydenix" ];
    }
    // lib.optionalAttrs (!isServer) {
      trusted-public-keys = [ lanCache.publicKey ];
      # Drop the LAN cache fast when the desktop is off, so substitutions do not
      # stall on a connect timeout before falling back to the internet caches.
      connect-timeout = 1;
      # Let the builder fetch its own inputs instead of shipping them from here.
      builders-use-substitutes = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };

    # The desktop has twice the threads and is idle most of the day, so the
    # client hands it the compiles that no cache can satisfy.
    distributedBuilds = !isServer;
    buildMachines = lib.optionals (!isServer) [
      {
        hostName = lanCache.host;
        sshUser = "hydenix";
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };

  # The nix-daemon runs as root and connects to the builder non-interactively,
  # so it cannot prompt to accept the desktop's host key.
  programs.ssh.knownHosts = lib.mkIf (!isServer) {
    "${lanCache.host}".publicKey = lanCache.sshPublicKey;
  };

  # The cache signing key is committed encrypted and decrypted with this host's
  # SSH key, so the cache survives a reinstall without regenerating keys. Only
  # the server declares it: the client has no business decrypting it.
  # sops-nix master already requires Go 1.26, which the pinned nixpkgs is too old
  # for, so its helper is built with the unstable toolchain.
  sops.package = (pkgs.unstable.callPackage inputs.sops-nix.outPath { }).sops-install-secrets;
  sops.secrets = lib.mkIf isServer {
    nix_serve_secret_key.sopsFile = ./modules/system/config/secrets/secrets.yaml;
  };

  # Export this machine's store over the LAN so the others can substitute paths
  # that were already built here instead of rebuilding them. Paths are signed
  # with the key above, so the clients only need the matching public key.
  services.nix-serve = lib.mkIf isServer {
    enable = true;
    package = pkgs.nix-serve-ng;
    secretKeyFile = config.sops.secrets.nix_serve_secret_key.path;
    inherit (lanCache) port;
    openFirewall = true;
  };
  boot.loader.systemd-boot.configurationLimit = 10;
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.lcdfilter = "default";
      subpixel.rgba = "rgb";
    };
  };

  # System Version - Don't change unless you know what you're doing (helps with system upgrades and compatibility)
  system.stateVersion = "25.05";
}
