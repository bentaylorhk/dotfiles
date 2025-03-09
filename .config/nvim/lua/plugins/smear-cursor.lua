-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
    "sphamba/smear-cursor.nvim",
    --enabled = false,
    opts = {
        {
            -- Match grubbox light fg
            --cursor_color = "#654735",
            cursor_color = nil,
            --stiffness = 0.6,
            --trailing_stiffness = 0.1,
            trailing_exponent = 1,
            smear_between_neighbor_lines = false,
            --gamma = 1,
        },
    },
}
