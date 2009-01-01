-- One TypeScript client per repository.
--
-- LazyVim resolves each server's root from the nearest root marker, so a nested
-- `package.json` (a repo's `tests/package.json`) spawns a second vtsls rooted at
-- that subdirectory beside the repo-rooted one. Both then serve the same buffers:
-- doubled analysis cost, and every diagnostic reported twice by workspace-wide
-- views. Pinning the root to the git checkout keeps exactly one client.
-- `root_markers` alone is not enough here: lspconfig/LazyVim set `root_dir`, and
-- that wins over markers.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        root_dir = function(source, on_dir)
          local dir = vim.fs.root(source, { ".git" })
          if on_dir then
            on_dir(dir)
            return nil
          end
          return dir
        end,
      },
    },
  },
}
