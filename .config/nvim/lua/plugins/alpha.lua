-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
    "goolord/alpha-nvim",
    opts = function()
        local dashboard = require("alpha.themes.dashboard")
        local logo = [[
                  ／l、             
        neovim  （ﾟ､ ｡ ７         
        ======    l  ~ヽ       
                  じしf_,)ノ
        ]]

        dashboard.section.header.val = vim.split(logo, "\n")
        -- stylua: ignore
        dashboard.section.buttons.val = {
          dashboard.button("f", "Find file",       "<cmd> lua LazyVim.pick()() <cr>"),
          dashboard.button("n", "New file",        "<cmd> ene <BAR> startinsert <cr>"),
          dashboard.button("r", "Recent files",    "<cmd> lua LazyVim.pick('oldfiles')() <cr>"),
          dashboard.button("g", "Find text",       "<cmd> lua LazyVim.pick('live_grep', { additional_args = { '--hidden', '--glob', '!.git/*' } })() <cr>"),
          dashboard.button("p", "Projects",        "<cmd> lua LazyVim.pick('projects')() <cr>"),
          dashboard.button("z", "Restore Session", "<cmd> lua require('persistence').load() <cr>"),
          dashboard.button("l", "Lazy",            "<cmd> Lazy <cr>"),
          dashboard.button("x", "Lazy Extras",     "<cmd> LazyExtras <cr>"),
          dashboard.button("m", "Mason",           "<cmd> Mason <cr>"),
          dashboard.button("c", "Config",          "<cmd> lua LazyVim.pick.config_files()() <cr>"),
          dashboard.button("s", "Settings",          "<cmd> e $MYVIMRC <cr>"),
          dashboard.button("q", "Quit",            "<cmd> qa <cr>"),
        }
        for _, button in ipairs(dashboard.section.buttons.val) do
            button.opts.hl = "AlphaButtons"
            button.opts.hl_shortcut = "AlphaShortcut"
        end
        dashboard.section.header.opts.hl = "AlphaHeader"
        dashboard.section.buttons.opts.hl = "AlphaButtons"
        dashboard.section.footer.opts.hl = "AlphaFooter"
        dashboard.opts.layout[1].val = 8
        return dashboard
    end,
}
