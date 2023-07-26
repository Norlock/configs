local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- workflow
    'nvim-lua/plenary.nvim',
    { 'nvim-treesitter/nvim-treesitter', cmd = 'TSUpdateSync' },
    { 'nvim-telescope/telescope.nvim',   tag = '0.1.2' },
    {
        dir = '~/Projects/nvim-traveller',
        init = function()
            vim.o.formatoptions = "tq"
        end
    },
    'ThePrimeagen/harpoon',

    -- Themes
    { "rebelot/kanagawa.nvim",       lazy = true },
    { "morhetz/gruvbox",             lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },
    'nvim-lualine/lualine.nvim',
    'xiyaowong/transparent.nvim',
    { "catppuccin/nvim", as = "catppuccin", lazy = true },

    {
        'neanias/everforest-nvim',
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme everforest]])
        end,
    },

    -- LSP
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',

    -- For luasnip users.
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    "ahmedkhalf/project.nvim",

    -- Comments
    'preservim/nerdcommenter',
})

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.o.formatoptions = "tq"
    end
})
