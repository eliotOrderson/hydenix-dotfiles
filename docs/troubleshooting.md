<img align="right" width="75px" alt="NixOS" src="https://github.com/HyDE-Project/HyDE/blob/master/Source/assets/nixos.png?raw=true"/>

# troubleshooting & issues

## nix errors

nix errors can be tricky to diagnose, but the below might assist in diagnosing the issue.

> [!TIP]
> rerun the command with `-v` to get more verbose output.
> you can also rerun the command with `--show-trace` to get a more detailed traceback.
> if the nix error is not clear, often the correct error message is somewhere in the *middle* of the error message.

## system errors & bugs

the following information is required when creating an issue, please provide as much as possible.
it's also possible to diagnose issues yourself with the information below.

1. **system logs**

   ```bash
   journalctl -b                                          # System logs
   sudo systemctl status home-manager-$HOSTNAME.service   # Home-manager status
   ```

2. **system information**

   ```bash
   nix-shell -p nix-info --run "nix-info -m"
   ```

## boot stops at `<<< NixOS Stage 1 >>>` with a missing device

symptom — the machine never reaches the login screen and ends with something like:

```text
waiting for device /dev/disk/by-uuid/b344100e-600e-4b82-8743-8c2ae46e52ea to appear......
Timed out waiting for device /dev/disk/by-uuid/b344100e-600e-4b82-8743-8c2ae46e52ea, trying to mount anyway.
mount: /mnt-root: special device /dev/disk/by-uuid/b344100e-600e-4b82-8743-8c2ae46e52ea does not exist.
An error occurred in stage 1 of the boot process, which must mount the
root filesystem on `/mnt-root` and then start stage 2.
```

**cause:** `hardware-configuration.nix` declares a device that is not on this
machine. Most often the config came from a different computer, or a disk was
repartitioned/reformatted so its UUID changed. NixOS copies device paths into
the initrd without checking they exist, which is why `nixos-rebuild` reported
success and the failure only appears now.

**fix**, from a live USB (or an older generation that still boots):

```bash
# 1. mount your root and enter it
sudo mount /dev/nvme0n1p2 /mnt && sudo mount /dev/nvme0n1p1 /mnt/boot
sudo nixos-enter --root /mnt

# 2. regenerate the hardware config for THIS machine
cd /home/<you>/hydenix-dotfiles
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# 3. verify before touching the bootloader
nix run .#check-fs

# 4. rebuild and reboot
sudo nixos-rebuild boot --flake .#hydenix
```

**avoid it next time:** run `nix run .#check-fs` before rebooting into a new
generation. It prints every declared device that does not exist, and the list of
devices that *do*. To confirm a built system rather than the config file, point
it at the generation:

```bash
nix run .#check-fs -- /nix/var/nix/profiles/system/etc/fstab
```

> [!NOTE]
> if the disk now uses a different filesystem (e.g. the old config said `btrfs`
> with `subvol=@` and the disk is now plain `xfs`), regenerating in step 2 fixes
> both the UUID *and* the filesystem type. Do not hand-edit only the UUID.

## theme select shows blank white tiles

symptom — pressing `mod + shift + T` opens the theme grid, but themes render as
empty light/white tiles: no wallpaper preview and no hint of the theme colors.
Picking one still applies the theme; only the tiles look blank.

**cause:** the grid is drawn by `~/.local/lib/hyde/theme.select.sh` (keybinding:
`$mainMod Shift, T` in `~/.config/hypr/keybindings.conf`). Each row passes the
theme's cached thumbnail as its rofi icon:

```text
~/.cache/hyde/thumbs/<sha1 of the wallpaper file>.sqre
```

The cache key is the sha1 of the wallpaper **content**, and the file is only
created once that wallpaper gets cached — when you switch to it, or when a cache
build runs. A theme you never switched to therefore has no thumbnail, rofi draws
the element background only, and the tile looks white. The theme itself is fine.
(`theme.select.sh -s` switches the menu between style 1, which uses `.sqre`, and
style 2, which uses `.quad`.)

**diagnose**

```bash
# the wallpaper a theme previews (the target of its wall.set link)
theme="Tokyo Night"
wall="$(readlink ~/.config/hyde/themes/"$theme"/wall.set)"

# is that wallpaper cached?
ls ~/.cache/hyde/thumbs/"$(sha1sum "$wall" | awk '{print $1}')".sqre

# list every theme without a cached preview
for d in ~/.config/hyde/themes/*/; do
  wall="$(readlink "$d/wall.set")"
  h="$(sha1sum "$wall" 2>/dev/null | awk '{print $1}')"
  [ -e "$HOME/.cache/hyde/thumbs/$h.sqre" ] || echo "missing: ${d%/}"
done
```

**fix** — rebuild the cache, then just reopen the menu (no restart needed):

```bash
hyde-shell reload                              # rebuild missing caches + re-apply the current theme
~/.local/lib/hyde/swwwallcache.sh -t ""        # cache only, skips what already exists
~/.local/lib/hyde/swwwallcache.sh -f           # force: recompute every thumbnail and dcol
~/.local/lib/hyde/swwwallcache.sh -t "Tokyo Night"         # one theme
~/.local/lib/hyde/swwwallcache.sh -w "/path/to/wall.png"   # one wallpaper
```

Only the previews the menu actually shows (one image per theme, much faster):

```bash
for d in ~/.config/hyde/themes/*/; do
  wall="$(readlink "$d/wall.set")"
  h="$(sha1sum "$wall" 2>/dev/null | awk '{print $1}')"
  [ -e "$HOME/.cache/hyde/thumbs/$h.sqre" ] || printf '%s\n' "$wall"
done >/tmp/missing-previews.txt

xargs -d '\n' -n1 -P"$(nproc)" -a /tmp/missing-previews.txt \
  ~/.local/lib/hyde/swwwallcache.sh -w
```

> [!NOTE]
> `hyde-shell reload` and `swwwallcache.sh -t ""` walk **every wallpaper of every
> theme** (≈800 images and ≈1 GB of cache here, several minutes). The loop above
> builds only the single preview per theme that the menu draws.

**speed** — the sweep is already parallel. `swwwallcache.sh` ends with

```bash
parallel --bar --link "fn_wallcache${mode}" ::: "${wallHash[@]}" ::: "${wallList[@]}"
```

so GNU parallel runs one job per wallpaper and uses every core by default (cap or
raise it with `--jobs` in `$PARALLEL_HOME/config`, classic `~/.parallel/config`).
What is slow is each job, not the scheduling: every wallpaper costs four
ImageMagick passes (`.thmb`, `.sqre`, `.blur`, `.quad`) plus a `wallbash.sh` dcol
pass, ≈10–15 s here — so a full 800-wallpaper sweep takes tens of minutes even at
8 jobs. The `--bar` line only makes it *look* sequential.

If all you want is the menu preview, a `.sqre` on its own costs ≈0.5 s:

```bash
thumbs="$HOME/.cache/hyde/thumbs"
for d in ~/.config/hyde/themes/*/; do
  wall="$(readlink "$d/wall.set")"
  h="$(sha1sum "$wall" | awk '{print $1}')"
  [ -e "$thumbs/$h.sqre" ] && continue
  magick "$wall"[0] -strip -thumbnail "500x500^" -gravity center -extent 500x500 \
    "$thumbs/$h.sqre.png" && mv "$thumbs/$h.sqre.png" "$thumbs/$h.sqre"
done
```

> [!NOTE]
> the `.sqre.png` intermediate matters: ImageMagick picks the encoder from the file
> suffix, so writing `.sqre` directly would produce a JPEG. This shortcut only
> builds previews — the dcol/colors for a theme are still generated the first time
> you actually switch to it.

**related cache files**

- `~/.cache/hyde/thumbs/<sha1>.{sqre,quad,thmb,blur}` — menu preview, the rofi
  wallpaper styles and the wallpaper/lockscreen thumbnails.
- `~/.cache/hyde/dcols/<sha1>.dcol` — the wallbash palette generated from that
  wallpaper (feeds rofi, waybar, GTK, dunst, …). If a theme's *colors* look
  ungenerated (plain light and unstyled rather than just an empty tile), it is the
  same cache: `swwwallcache.sh -w <wallpaper>` rebuilds its dcol, `-f` rebuilds
  all of them.
- Both are keyed by wallpaper content hash, so moving or renaming a wallpaper does
  not invalidate them; only editing the image does.
- `~/.cache/hyde` is runtime state, not home-manager output: it survives rebuilds,
  is untouched by `hydenix.hm.theme.themes`, and is safe to delete
  (`rm -rf ~/.cache/hyde/thumbs/*` and rebuild).
