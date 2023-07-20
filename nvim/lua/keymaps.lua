local silent_options = { silent = true, noremap = true }

vim.keymap.set('i', 'jj', '<Esc>', {})
vim.keymap.set('n', '<Esc>', ':nohls<Cr>', silent_options)
vim.keymap.set('i', '<C-s>', '<Esc>:w<Cr>', silent_options)
vim.keymap.set('n', '<C-s>', ':w<Cr>', silent_options)
vim.keymap.set('n', '_', ':move -2<Cr>', silent_options)
vim.keymap.set('n', '+', ':move +1<Cr>', silent_options)

local reload_modules = function()
    local plenary = require("plenary.reload")
    plenary.reload_module("nvim-traveller")
end

vim.keymap.set('n', '<leader>-', reload_modules, silent_options)

-- Yank to clipboard
vim.keymap.set('n', '<leader>p', '"+', silent_options)
vim.keymap.set('v', '<leader>p', '"+', silent_options)

-- Navigation
local move_left = ':wincmd h<Cr>'
local move_down = ':wincmd j<Cr>'
local move_up = ':wincmd k<Cr>'
local move_right = ':wincmd l<Cr>'
local move_window_left = '<C-w>H'
local move_window_down = '<C-w>J'
local move_window_up = '<C-w>K'
local move_window_right = '<C-w>L'
local tab_left = ':tabprevious<Cr>'
local tab_right = ':tabnext<Cr>'
local window_only = ':only<Cr>'
local exit_term = '<C-\\><C-n>'

vim.keymap.set('n', '<A-h>', move_left, silent_options)
vim.keymap.set('n', '<A-j>', move_down, silent_options)
vim.keymap.set('n', '<A-k>', move_up, silent_options)
vim.keymap.set('n', '<A-l>', move_right, silent_options)
vim.keymap.set('n', '<A-Left>', move_left, silent_options)
vim.keymap.set('n', '<A-Down>', move_down, silent_options)
vim.keymap.set('n', '<A-Up>', move_up, silent_options)
vim.keymap.set('n', '<A-Right>', move_right, silent_options)

vim.keymap.set('n', '<A-H>', move_window_left, silent_options)
vim.keymap.set('n', '<A-J>', move_window_down, silent_options)
vim.keymap.set('n', '<A-K>', move_window_up, silent_options)
vim.keymap.set('n', '<A-L>', move_window_right, silent_options)
vim.keymap.set('n', '<A-,>', tab_left, silent_options)
vim.keymap.set('n', '<A-.>', tab_right, silent_options)
vim.keymap.set('n', '<A-o>', window_only, silent_options)

vim.keymap.set('t', '<A-h>', exit_term .. move_left, silent_options)
vim.keymap.set('t', '<A-j>', exit_term .. move_down, silent_options)
vim.keymap.set('t', '<A-k>', exit_term .. move_up, silent_options)
vim.keymap.set('t', '<A-l>', exit_term .. move_right, silent_options)
vim.keymap.set('t', '<A-H>', exit_term .. move_window_left, silent_options)
vim.keymap.set('t', '<A-J>', exit_term .. move_window_down, silent_options)
vim.keymap.set('t', '<A-K>', exit_term .. move_window_up, silent_options)
vim.keymap.set('t', '<A-L>', exit_term .. move_window_right, silent_options)
vim.keymap.set('t', '<A-,>', exit_term .. tab_left, silent_options)
vim.keymap.set('t', '<A-.>', exit_term .. tab_right, silent_options)
vim.keymap.set('t', '<A-o>', exit_term .. window_only, silent_options)

-- Terminal
vim.keymap.set('n', '<leader>ts', ':vsplit<Cr>:terminal<Cr>i', silent_options)
vim.keymap.set('n', '<leader>tt', ':tabe<Cr>:terminal<Cr>i', silent_options)
vim.keymap.set('n', '<leader>tr', ':terminal<Cr>i', silent_options)
vim.keymap.set('t', '<leader>e', exit_term, silent_options)

-- Telescope
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>g', builtin.git_files, {})
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>a', builtin.live_grep, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', '<space>f', vim.lsp.buf.format, {})
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, {})
vim.keymap.set('n', '<Leader>q', vim.lsp.buf.code_action, {})

vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
vim.keymap.set('n', 'gr', builtin.lsp_references, {})

-- Filemanager
local traveller = require('nvim-traveller')
traveller.setup({ replace_netrw = true, sync_cwd = true })

vim.keymap.set('n', '-', traveller.open_navigation, {})
vim.keymap.set('n', '<leader>d', traveller.open_telescope_search, silent_options)
