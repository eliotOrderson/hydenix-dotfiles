-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = ""

vim.g.clipboard = nil

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Yank to OSC 52",
  callback = function()
    if vim.v.event.operator == "y" then
      require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
    end
  end,
})
if vim.g.neovide then
  vim.g.snacks_animate = true
  vim.o.guifont = "JetBrainsMono Nerd Font:h18"
  vim.g.neovide_opacity = 0.95
end

vim.opt.exrc = true
vim.opt.secure = true  -- 安全模式，避免执行危险命令

vim.opt_local.swapfile = false
vim.opt_local.redrawtime = 2000
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting

-- vim.g.multi_cursor_use_default_mapping = 0
-- vim.g.multi_cursor_start_word_key = "<C-n>"
-- vim.g.multi_cursor_select_all_word_key = "<M-a>"
-- vim.g.multi_cursor_start_key = "g<C-n>"
-- vim.g.multi_cursor_select_all_key = "g<A-n>"
-- vim.g.multi_cursor_next_key = "<C-n>"
-- vim.g.multi_cursor_prev_key = "<C-p>"
-- vim.g.multi_cursor_skip_key = "<C-x>"
-- vim.g.multi_cursor_quit_key = "<Esc>"
