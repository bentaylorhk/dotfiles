-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                -- LSP Servers
                "clangd", -- c/cpp
                "pyright", -- python
                "lua_ls", -- lua
                "bashls", -- bash
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                },
            },
        },
        setup = {
            clangd = function(_, opts)
                local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
                require("clangd_extensions").setup(
                    vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
                )
                return false
            end,
        },
    },

    {
        "mfussenegger/nvim-lint",
        --config = function()
        --    require("lint").linters_by_ft = {
        opts = {
            c = { "clang-tidy" },
            cpp = { "clang-tidy" },
            python = { "pylint" },
            sh = { "shellcheck" },
            lua = { "luacheck" },
            json = { "checkstyle" },
            yaml = { "yamllint" },
            markdown = { "markdownlint" },
            dockerfile = { "hadolint" },
        },
        --end,
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                c = { "clang-format" },
                cpp = { "clang-format" },
                python = { "black" },
                sh = { "shfmt" },
                lua = { "stylua" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
            },
        },
    },
}
