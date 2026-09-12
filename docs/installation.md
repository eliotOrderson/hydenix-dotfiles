<img align="right" width="75px" alt="NixOS" src="https://github.com/HyDE-Project/HyDE/blob/master/Source/assets/nixos.png?raw=true"/>

# installation

> [!CAUTION]
> the templated flake is designed for a minimal install of nixos. install nixos first, then follow the instructions below.

## 1. initialize the flake template

```bash
# create a new directory and initialize the template
mkdir hydenix && cd hydenix
nix flake init -t github:richen604/hydenix
```

## 2. configure your system

edit `configuration.nix` following the detailed comments:

- **optional:** see [module options](./options.md) for advanced configuration

## 3. generate hardware configuration

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

## 4. initialize git repository

```bash
git init && git add .
```

we do this because flakes must be managed via git. and its good practice to version control your configuration

## 5. build and switch to the new configuration

```bash
# verify the declared disks actually exist on THIS machine before building
nix run .#check-fs

sudo nixos-rebuild switch --flake .#hydenix
```

> [!IMPORTANT]
> `hardware-configuration.nix` describes **one** computer's disks. If you copied
> your config from another machine (or reformatted a disk), regenerate it in
> step 3 first. NixOS does not validate device paths when building — a stale
> UUID produces a *successful* build and then a machine that hangs at boot with
> `Timed out waiting for device /dev/disk/by-uuid/...`. `nix run .#check-fs`
> catches this before you reboot. See [moving your config to a new
> computer](#moving-your-config-to-a-new-computer).

> [!NOTE]
> if you made mistakes, it will fail here. try following:
>
> - read the error carefully, it may be self-explanatory
> - troubleshooting steps in [troubleshooting & issues](./troubleshooting.md)
> - read the [faq](./faq.md), it may have the answer you're looking for
> - please don't hesitate to ask in [discord](https://discord.gg/AYbJ9MJez7) or [github discussions](https://github.com/richen604/hydenix/discussions)!

## 6. launch hydenix

reboot and log in.

> [!IMPORTANT]
> do not forget to set your password
>
> ```bash
> passwd
> ```

you can generate the theme cache with the below:

```bash
hyde-shell reload

# cache only, without re-applying the current theme
~/.local/lib/hyde/swwwallcache.sh -t ""
```

the theme menu (`mod + shift + T`) previews themes from this cache; see
[troubleshooting](./troubleshooting.md#theme-select-shows-blank-white-tiles) if
the tiles show up blank.

## moving your config to a new computer

`hardware-configuration.nix` is the one file in this repo that is **not**
portable. It records partition UUIDs, filesystem types and CPU specifics for a
single machine, and it stays in git (a flake's source is a git snapshot, so an
untracked hardware config would be invisible to the build and every
`fileSystem` would silently disappear).

Reusing a config on a different computer therefore requires regenerating it:

```bash
git clone <your-config> hydenix && cd hydenix

# 1. replace the old machine's disks with this machine's
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# 2. confirm every declared device exists here (catches step 1 being skipped)
nix run .#check-fs

# 3. commit so the flake source includes it, then build
git add hardware-configuration.nix && git commit -m "hardware: $(hostname)"

# `boot` rather than `switch`: this changes the initrd, and a bad initrd is
# only detectable at the next boot.
sudo nixos-rebuild boot --flake .#hydenix
```

> [!WARNING]
> skipping step 1 is the classic failure. The build succeeds, then the machine
> stops at `<<< NixOS Stage 1 >>>` with
> `mount: /mnt-root: special device /dev/disk/by-uuid/<other-machine-uuid> does not exist`
> and waits forever. See [troubleshooting](./troubleshooting.md#boot-stops-at-nixos-stage-1-with-a-missing-device).

the same applies after **repartitioning or reformatting a disk** on the machine
you already have: the UUIDs change, so step 1 must be re-run.
