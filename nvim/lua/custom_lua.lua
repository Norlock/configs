-- Use completion-nvim in every buffer
local lspconfig = require('lspconfig')
local actions = require('telescope.actions')

lspconfig.tsserver.setup{}
lspconfig.html.setup{}
lspconfig.cssls.setup{}
lspconfig.jsonls.setup{}
lspconfig.vimls.setup{}
lspconfig.rust_analyzer.setup{}

require('nvim-web-devicons').setup()

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        -- Disable the default <c-x> mapping
        ["<C-x>"] = false,

        -- Create a new <c-s> mapping
        ["<C-s>"] = actions.select_horizontal,
        ["<Esc>"] = actions.close
      },
    },
  }
}

require('nvim-treesitter.configs').setup {
    -- Modules and its options go here
    highlight = { enable = true },
    incremental_selection = { enable = true },
    refactor = {
        highlight_definitions = { enable = true },
        smart_rename = { enable = true },
        navigation = { enable = true },
    },
    textobjects = { enable = true },
}

completion_chain_complete_list = {
  { complete_items = { 'lsp' } },
  { complete_items = { 'buffers' } },
  { mode = { '<c-p>' } },
  { mode = { '<c-n>' } }
}
