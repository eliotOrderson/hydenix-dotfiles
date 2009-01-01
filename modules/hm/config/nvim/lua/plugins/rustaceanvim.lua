local function load_rust_analyzer_json()
  local json_path = vim.fn.getcwd() .. "/rust-analyzer.json"
  if vim.fn.filereadable(json_path) == 1 then
    local ok, json = pcall(vim.fn.readfile, json_path)
    if ok then
      local decoded = vim.fn.json_decode(table.concat(json, "\n"))
      return decoded or {}
    end
  end
  return {}
end

vim.g.rustaceanvim = {
  server = {
    auto_attach = true,
    settings = {
      ["rust-analyzer"] = vim.tbl_deep_extend(
        "force",
        {
          procMacro = { enable = true },
          cargo = {
            allFeatures = true,
            buildScripts = { enable = true },
          },
        },
        load_rust_analyzer_json()
      ),
    },
  },
}
return {

  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    lazy = false, -- This plugin is already lazy
  },
}
