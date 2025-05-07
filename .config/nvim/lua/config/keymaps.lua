-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function open_diagnostics_bottom()
  local opts = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    relative = "editor",
    width = math.floor(vim.o.columns * 0.95),
    height = 5,
    row = vim.o.lines - 6,  -- Adjust to ensure it's above the command line
    col = math.floor(vim.o.columns * 0.025),
  }
  vim.diagnostic.open_float(nil, opts)
end

vim.keymap.set('n', '<leader>e', open_diagnostics_bottom, { desc = "Show diagnostics at bottom" })
