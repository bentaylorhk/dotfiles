-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

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
