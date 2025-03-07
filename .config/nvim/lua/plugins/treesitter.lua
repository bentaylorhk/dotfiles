-- Benjamin Michael Taylor (bentaylorhk)
-- 2025

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
  opts = {
    highlight = { enabled = true },
    indent = { enable = true },
    ensure_installed = {
      -- Common languages
      "c",
      "cpp",
      "python",
      "bash",
      "lua",
      "java",
      "rust",
      "go",

      -- Shell languages
      "bash",
      "perl",
      "ruby",
      "nix",
      "awk",

      -- Data formats
      "toml",
      "yaml",
      "json",
      "xml",
      "csv",

      -- Web languages
      "html",
      "css",
      "javascript",
      "typescript",
      "php",
      "sql",

      -- Documents
      "latex",
      "bibtex",
      "markdown",
      "markdown_inline",
      "luadoc",

      -- Build languages
      "make",
      "cmake",
      "ninja",
      "meson",
      "dockerfile",

      -- Config files
      "ini",
      "vim",
      "vimdoc",
      "tmux",

      -- Git
      "git_config",
      "gitattributes",
      "gitcommit",
      "gitignore",

      -- Misc
      "diff",
      "regex",
      "query",
      "printf",
    }
  }
}
