-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

--vim.api.nvim_create_autocmd("BufWritePre", {
--  desc = "Format file on save",
--  pattern = "*",
--  callback = function(args)
--    require("conform").format({ bufnr = args.buf })
--  end,
--})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap and check for spell in text filetypes",
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

