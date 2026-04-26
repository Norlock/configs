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
    keymap = {
        preset = "default",
        -- Use 'accept' to confirm the selected item
        -- Use 'fallback' so <CR> still creates a new line when the menu is closed
        ['<Cr>'] = { 'accept', 'fallback' },
    },
    completion = {
        -- 'prefix' will fuzzy match on the text before the cursor
        -- 'full' will fuzzy match on the text before _and_ after the cursor
        -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
        keyword = { range = 'full' },

        -- Disable auto brackets
        -- NOTE: some LSPs may add auto brackets themselves anyway
        accept = { auto_brackets = { enabled = false }, },

        -- Don't select by default, auto insert on selection
        list = { selection = { preselect = true, auto_insert = false } },

        -- Show documentation when selecting a completion item
        documentation = { auto_show = true, auto_show_delay_ms = 500 },

        -- Display a preview of the selected item on the current line
        ghost_text = { enabled = false },
    },
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
