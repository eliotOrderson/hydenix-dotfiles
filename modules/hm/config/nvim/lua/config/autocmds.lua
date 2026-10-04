-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- nvim-ufo rebuilds folds from its provider every time a buffer is displayed, so the
-- closed state of a `za` fold is lost on unload. Views persist that state per file.
local function named_file_buffer(buf)
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

vim.api.nvim_create_autocmd("BufWinLeave", {
  desc = "Save folds",
  callback = function(args)
    if named_file_buffer(args.buf) then
      vim.cmd("silent! mkview")
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Restore folds",
  callback = function(args)
    if named_file_buffer(args.buf) then
      vim.cmd("silent! loadview")
    end
  end,
})
