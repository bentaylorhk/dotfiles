-- Benjamin Michael Taylor (bentaylorhk)
-- 2025
--[[
return {
    {
        "morhetz/gruvbox",

        -- Load immediately
        lazy = false,

        -- High priority, to load before other plugins
        priority = 1000,

        config = function()
            vim.cmd("colorscheme gruvbox")
            vim.o.background = "light"
        end,
    },
}
]]

return {
    { "savq/melange-nvim" },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = function()
                local term = vim.loop.os_getenv("TERM")

                if term == "st-256color" then
                    return "gruvbox"
                elseif term == "linux" then
                    return "melange"
                elseif term == "tmux-256color" then
                    return "default"
                else
                    return "default"
                end
            end,
        },
    },
}
