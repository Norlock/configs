local catpucchin = {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha"
        })

        vim.cmd.colorscheme "catppuccin"
    end
}

local lualine = {
    'nvim-lualine/lualine.nvim',
    opts = {}
}

local nvim_web_decivons = { "nvim-tree/nvim-web-devicons", opts = {} }


-- Install LSP's
-- sudo pacman -S lua-language-server rust-analyzer
-- gleam vscode-css-languageserver tailwindcss-language-server
local lsp_config = {
    "neovim/nvim-lspconfig",
    config = function()
        vim.lsp.enable("lua_ls")
        vim.lsp.enable("gleam")
        vim.lsp.enable("rust_analyzer")
        vim.lsp.enable("tailwindcss")
        vim.lsp.enable("typescript")
        vim.lsp.enable("cssls")

        vim.lsp.config("tailwindcss", {
            filetypes = {
                "html",
                "astro",
                "javascript",
                "typescript",
                "react",
                "gleam",
            },
            settings = {
                tailwindCSS = {
                    includeLanguages = {
                        gleam = "javascript",
                    },
                    classFunctions = {
                        "class",
                        "classes",
                    },
                },
            }
        })
    end
}

local fzf_lua = {
    "ibhagwan/fzf-lua",
    opts = {
        winopts = {
            height = 0.95, -- window height
            width  = 0.95, -- window width
            row    = 0.25, -- window row position (0=top, 1=bottom)
            col    = 0.50, -- window col position (0=left, 1=right)
        },                 -- UI Options
    }
}

local tree_sitter =
{
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
       require('nvim-treesitter').install({ "rust", "lua", "vim", "vimdoc", "javascript", "gleam", "html", "css", "json", "markdown" }):wait(300000)
    end
}

local blink = {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = { preset = 'enter' },

        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = true } },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
}

local comment = {
    'numToStr/Comment.nvim',
    opts = {
        -- add any options here
    }
}

local oil = {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
}

return {
    -- theming
    catpucchin,
    lualine,
    nvim_web_decivons,

    -- lsp
    lsp_config,

    -- tree sitter
    tree_sitter,

    -- fuzzy
    fzf_lua,

    -- autocomplete
    blink,

    -- comment
    comment,

    -- file manager
    oil
}
