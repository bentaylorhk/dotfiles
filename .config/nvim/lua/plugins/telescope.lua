-- Benjamin Michael Taylor
-- 2025

return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local ts = require("telescope")
        ts.setup({
            pickers = {
                find_files = {
                    hidden = true,
                },
            },
        })
    end,
}
