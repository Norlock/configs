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
	{ 'nvim-telescope/telescope.nvim', tag = '0.1.6' },
	{
        dir = '~/Projects/nvim-traveller-rs',
		--"norlock/nvim-traveller-rs",
		--build = "./prepare.sh"
	},
	{
		dir = '~/Projects/nvim-traveller-buffers',
	},
	--'norlock/nvim-traveller-buffers',
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		opts = {} -- this is equalent to setup({}) function
	},
	'mfussenegger/nvim-dap',

	-- Themes
	{ "rebelot/kanagawa.nvim",         lazy = true },
	{ "morhetz/gruvbox",               lazy = true },
	{ "nvim-tree/nvim-web-devicons",   lazy = true },

	'nvim-lualine/lualine.nvim',

	{
		"catppuccin/nvim",
		as = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe" -- latte, frappe, macchiato, mocha
			})

			vim.cmd.colorscheme("catppuccin")
		end
	},

	-- LSP
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"williamboman/mason.nvim",
	'neovim/nvim-lspconfig',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-nvim-lsp-signature-help',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-cmdline',
	'hrsh7th/nvim-cmp',

	-- For luasnip users.
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp"
	},
	'saadparwaiz1/cmp_luasnip',

	-- Comments
	'preservim/nerdcommenter',
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.o.formatoptions = "tq"
	end
})
