-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
    { "ellisonleao/gruvbox.nvim" },
    { "savq/melange-nvim" },
    {
        "LazyVim/LazyVim",
        priority = 1000,
        config = function()
            local term = vim.loop.os_getenv("TERM") or ""

            local colourscheme = "default"
            local background = "dark"

            if term == "alacritty" or term == "st-256color" then
                colourscheme = "gruvbox"
                background = "light"
            elseif term == "linux" then
                colourscheme = "melange"
                background = "dark"
                return "melange"
            elseif term:match("tmux-256color") then
                colourscheme = "default"
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
