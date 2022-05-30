local actions = require('telescope.actions')

require'nvim-web-devicons'.setup {
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
}

require'telescope'.setup {
  defaults = {
    mappings = {
      i = {
        -- Disable the default <c-x> mapping
        ["<C-x>"] = false,

        -- Create a new <c-s> mapping
        ["<Esc>"] = actions.close
      },
    },
  }
}

require'nvim-treesitter.configs'.setup {
    highlight = { enable = true },
    incremental_selection = { enable = true },
    refactor = {
        highlight_definitions = { enable = true },
        smart_rename = { enable = true },
        navigation = { enable = true },
    },
    textobjects = { enable = true },
}
