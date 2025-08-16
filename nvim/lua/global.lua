vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.swapfile = false
vim.o.formatoptions = "tq"
vim.o.smartcase = true
vim.o.ignorecase = true

-- UI
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.textwidth = 120
vim.opt.termguicolors = true
vim.o.splitright = true -- Splits pane to the right
vim.o.splitbelow = true -- Splits pane below
vim.o.scrolloff = 3
vim.o.formatoptions = "tq"

-- Tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

--vim.api.nvim_create_autocmd('FileType', {
--    callback = function(args)
--        local filetype = args.match
--        local lang = vim.treesitter.language.get_lang(filetype)
--
--        if vim.treesitter.language.add(lang) then
--            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
--            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
--            vim.treesitter.start()
--        end
--    end,
--})
