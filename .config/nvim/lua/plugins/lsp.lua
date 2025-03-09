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
                "basedpyright", -- python
                "lua_ls", -- lua
                "bashls", -- bash
            },
            automatic_installation = true,
        },
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = { "p00f/clangd_extensions.nvim" },
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
                        "--limit-results=50", -- Reduce completion results
                        "--malloc-trim", -- Force memory cleanup
                        "--pch-storage=memory", -- Optimize precompiled headers
                    },
                    settings = {
                        clangd = {
                            index = {
                                exclude = { ".git", "node_modules", "build" },
                            },
                        },
                    },
                },
                basedpyright = {
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "strict", -- Slower than "basic"
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnostcMode = "openFilesOnly", -- Avoids scanning entire project
                                indexing = false, -- Disabling background indexing saves CPU
                            },
                        },
                    },
                },

                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                maxPreLoad = 1000,
                                preloadFileSize = 500,
                            },
                            telemetry = { enable = false },
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
    },

    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                linters_by_ft = {
                    c = { "clang-tidy" },
                    cpp = { "clang-tidy" },
                    python = { "ruff" }, -- quicker than pylint
                    sh = { "shellcheck" },
                    lua = { "luacheck" },
                    json = { "checkstyle" },
                    yaml = { "yamllint" },
                    markdown = { "markdownlint" },
                    dockerfile = { "hadolint" },
                },
                vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                    callback = function()
                        require("lint").try_lint()
                    end,
                }),
            }
        end,
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
