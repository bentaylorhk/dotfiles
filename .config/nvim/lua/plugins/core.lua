-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
  { "ellisonleao/gruvbox.nvim" },
  { "bentaylorhk/choihung.nvim" },
  --{ "savq/melange-nvim" },
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
      local colourscheme = vim.loop.os_getenv("COLOURSCHEME") or "gruvbox"
      local background = "light";

      if colourscheme == "gruvbox" then
        background = "light";
        require("gruvbox").setup({
          contrast = "soft",
          transparent_mode = false,
          dim_inactive = false,
        })
      elseif colourscheme == "choihung" then
        background = "dark";
      else
        error("Invalid colourscheme name: " .. colourscheme)
      end

      vim.opt.background = background

      vim.cmd("colorscheme " .. colourscheme)
    end,
  },
}
