-- Install LSPs:
-- sudo pacman -S lua-language-server rust-analyzer
-- gleam vscode-css-languageserver tailwindcss-language-server

vim.pack.add(require("plugins"), { load = true })

require("catppuccin").setup({ flavour = "mocha" })
vim.cmd.colorscheme("catppuccin")

require("lualine").setup({})
require("nvim-web-devicons").setup({})

vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("ts_ls")
vim.lsp.enable("cssls")
vim.lsp.enable("gleam")

require("nvim-treesitter").setup({})

require("nvim-treesitter").install({
    "rust", "lua", "vim", "vimdoc", "javascript",
    "gleam", "html", "css", "json", "markdown",
}):wait(300000)

require("fzf-lua").setup({
    winopts = {
        height = 0.95,
        width  = 0.95,
        row    = 0.25,
        col    = 0.50,
    },
})

require("blink.cmp").setup({
    keymap = { preset = "default" },
    completion = { documentation = { auto_show = false } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },
    fuzzy = { implementation = "rust" },
})

require("Comment").setup({})
require("oil").setup({})
require("render-markdown").setup({})
