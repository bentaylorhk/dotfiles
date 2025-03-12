-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {

    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {

                -- Formatters
                "clang-format",
                "black", -- python
                "shfmt", -- sh
                "stylua", -- lua
                "prettier", -- json/markup
            },
            auto_update = true, -- Automatically update tools
            run_on_start = true, -- Run installation on startup
        },
    },

    {
        "williamboman/mason-lspconfig.nvim",
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
        opts = {
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
            linters = {
                luacheck = {
                    -- Disables "undefined variable" errors in nvim config files
                    args = { "--globals", "vim" }, -- Allow `vim` as a global variable
                },
            },
        },
    },

    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },

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

            formatters = {
                clang_format = {
                    prepend_args = { "--style=file", "--fallback-style=LLVM" },
                },
                shfmt = {
                    prepend_args = { "-i", "2" },
                },
            },
        },
        config = function()
            require("conform").setup({
                format_on_save = function(bufnr)
                    -- Disable autoformat on certain filetypes
                    local ignore_filetypes = { "sql" }
                    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                        return
                    end

                    -- Disable with a global or buffer-local variable
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        return
                    end

                    -- Disable autoformat for files in a certain path
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    if bufname:match("/node_modules/") then
                        return
                    end

                    return { timeout_ms = 500, lsp_format = "fallback" }
                end,
            })

            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                    -- FormatDisable! will disable formatting just for this buffer
                    vim.b.disable_autoformat = true
                else
                    vim.g.disable_autoformat = true
                end
            end, {
                desc = "Disable autoformat-on-save",
                bang = true,
            })

            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, {
                desc = "Re-enable autoformat-on-save",
            })
        end,
    },
}
