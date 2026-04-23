local gh = function(x) return 'https://github.com/' .. x end

return {
    -- theming
    gh("catppuccin/nvim"),
    gh("nvim-lualine/lualine.nvim"),
    gh("nvim-tree/nvim-web-devicons"),
    gh("nvim-mini/mini.nvim"),
    gh("MeanderingProgrammer/render-markdown.nvim"),

    -- lsp
    gh("neovim/nvim-lspconfig"),

    -- tree sitter
    gh("nvim-treesitter/nvim-treesitter"),

    -- fuzzy
    gh("ibhagwan/fzf-lua"),

    -- autocomplete
    { src = gh("saghen/blink.cmp"), version = "v1" },
    gh("rafamadriz/friendly-snippets"),

    -- comment
    gh("numToStr/Comment.nvim"),

    -- file manager
    gh("stevearc/oil.nvim"),
}
