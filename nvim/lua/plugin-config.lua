-- Set up nvim-cmp
local cmp = require("cmp")

local cmp_mappings = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    --["<Tab>"] = cmp.mapping(function(fallback)
    --if luasnip.expand_or_jumpable() then
    --luasnip.expand_or_jump()
    --else
    --fallback()
    --end
    --end, { "i", "s" }),
    --["<S-Tab>"] = cmp.mapping(function(fallback)
    --if luasnip.jumpable(-1) then
    --luasnip.jump(-1)
    --else
    --fallback()
    --end
    --end, { "i", "s" }),
})

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp_mappings,
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'luasnip' },
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Lua
require('lspconfig').lua_ls.setup {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}

require('lspconfig').rust_analyzer.setup {}
require('lspconfig').wgsl_analyzer.setup {}
require('lspconfig').tsserver.setup {}
require('lspconfig').html.setup {}
require('lspconfig').cssls.setup {}
require('lspconfig').jsonls.setup {}
require('lspconfig').gopls.setup {}
require('lspconfig').taplo.setup {}
require('lspconfig').svelte.setup {}
require('lspconfig').taplo.setup {}
require('lspconfig').lua_ls.setup {}
require('lspconfig').yamlls.setup {
    settings = {
        yaml = {
            format = {
                enable = true,
                singleQuote = false,
                bracketSpacing = true
            },
        }
    }
}


require("mason").setup()

-- Telescope
local actions = require("telescope.actions")
local telescope = require("telescope")

telescope.setup({
    defaults = {
        previewer = true,
        mappings = {
            i = {
                ["<Esc>"] = actions.close,
            },
        },
    },
})

-- Lualine
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

require('nvim-treesitter.configs').setup {
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "rust", "lua", "vim", "vimdoc", "wgsl" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
        enable = true
    },
}
