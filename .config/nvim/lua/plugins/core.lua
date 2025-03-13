-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
  { "ellisonleao/gruvbox.nvim" },
  { "savq/melange-nvim" },
  {
    "LazyVim/LazyVim",
    priority = 1000,

    opts = {
      news = {
        -- Disable changelog pop-up
        lazyvim = false,
        newvim = false,
      },
    },
    config = function()
      local term = vim.loop.os_getenv("TERM") or ""

      local colourscheme = "default"
      local background = "dark"

      if term == "alacritty" or term == "xterm-256color" or "tmux-256color" then
        colourscheme = "gruvbox"
        background = "light"
      elseif term == "linux" then
        colourscheme = "melange"
        background = "dark"
        return "melange"
      end

      vim.opt.background = background

      if colourscheme == "gruvbox" then
        require("gruvbox").setup({
          contrast = "soft",
          transparent_mode = false,
          dim_inactive = false,
        })
      end

      vim.cmd("colorscheme " .. colourscheme)
    end,
  },
}
