-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

--vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--    callback = function()
--        -- try_lint without arguments runs the linters defined in `linters_by_ft`
--        -- for the current filetype
--        require("lint").try_lint()
--    end,
--})

vim.api.nvim_create_autocmd({"FileType"}, {
  desc = "Disable New Line Comment",
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove { "c", "r", "o" }
  end,
  --group = general,
})
