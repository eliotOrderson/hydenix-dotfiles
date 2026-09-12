{ pkgs, ... }:
{
  hydenix.hm.git.enable = true;
  hydenix.hm.git.name = "eliot";
  hydenix.hm.git.email = "eliotorderson@gmail.com";

  # `programs.git.lfs` writes the same global config that `git lfs install` would:
  #
  #   filter.lfs.process = git-lfs filter-process
  #   filter.lfs.clean   = git-lfs clean -- %f
  #   filter.lfs.smudge  = git-lfs smudge -- %f
  #   filter.lfs.required = true
  #
  # and pulls `git-lfs` into home.packages.
  #
  # Do NOT also set these by hand in `settings` below — home-manager sets
  # filter.lfs.* itself, and a duplicate key here would collide with it.
  #
  # Why this matters: home-manager writes ~/.config/git/config as a read-only
  # symlink into /nix/store, so `git lfs install` can never write there:
  #   error: could not lock config file ~/.config/git/config: Read-only file system
  # Declaring it here instead means LFS works after every rebuild with no manual
  # `git lfs install`. Running `git lfs install` is therefore unnecessary — and
  # `git config --global <key>` will fail by design, since this file is generated.
  programs.git.lfs.enable = true;

  programs.git.settings = {
    init.defaultBranch = "main";
    pull.rebase = false;

    # Sensible global defaults
    push.autoSetupRemote = true;
    rebase.autoStash = true;
    merge.conflictStyle = "zdiff3";
    fetch.prune = true;

    # `gh auth setup-git` cannot write the read-only file either (see above), so the
    # GitHub credential helper is declared here; gh keeps its token in ~/.config/gh/hosts.yml.
    credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
  };
}
