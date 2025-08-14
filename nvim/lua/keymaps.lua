local silent_options = { silent = true, noremap = true }

vim.keymap.set('i', 'jj', '<Esc>', {})
vim.keymap.set('n', '<Esc>', ':nohls<Cr>', silent_options)
vim.keymap.set('i', '<C-s>', '<Esc>:w<Cr>', silent_options)
vim.keymap.set('n', '<C-s>', ':w<Cr>', silent_options)
vim.keymap.set('n', '_', ':move -2<Cr>', silent_options)
vim.keymap.set('n', '+', ':move +1<Cr>', silent_options)

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
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>f', fzf.files, {})
vim.keymap.set('n', '<leader>g', fzf.git_files, {})
vim.keymap.set('n', '<leader>a', fzf.grep_project, {})
vim.keymap.set('n', '<leader>b', fzf.buffers, {})

local function format()
    if vim.bo.filetype == 'svelte' or vim.bo.filetype == 'typescript' or vim.bo.filetype == 'javascript' then
        local path = vim.fn.expand('%:p:h');
        local file = vim.fn.expand('%:p:t');

        vim.fn.system("cd " .. path .. " && npx prettier --write " .. file)
        vim.cmd(":e")
    else
        vim.lsp.buf.format()
    end
end

vim.keymap.set('n', '<space>f', format, {})
vim.keymap.set('n', '<leader>s', ":ISwap<Cr>", {})
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, {})
vim.keymap.set('n', '<Leader>q', vim.lsp.buf.code_action, {})
vim.keymap.set('n', '<M-k>', '<cmd>cprev<Cr>', silent_options)
vim.keymap.set('n', '<M-j>', '<cmd>cnext<Cr>', silent_options)
vim.keymap.set('n', '<M-d>', vim.diagnostic.setqflist, silent_options)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', '<space>d', vim.diagnostic.open_float)

vim.keymap.set('n', 'gd', fzf.lsp_definitions, {})
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
vim.keymap.set('n', 'gr', fzf.lsp_references, {})

local dap = require('dap');
vim.keymap.set('n', '<space>b', dap.toggle_breakpoint)
vim.keymap.set('n', '<space>c', dap.continue)
vim.keymap.set('n', '<space>so', dap.step_over)
vim.keymap.set('n', '<space>si', dap.step_over)

-- Filemanager
local nvim_traveller_rs = require('nvim-traveller-rs')

vim.keymap.set('n', '-', nvim_traveller_rs.open_navigation, {})
--vim.keymap.set('n', '<leader>d', nvim_traveller_rs.directory_search, silent_options)
--vim.keymap.set('n', '<leader>g', nvim_traveller_rs.git_file_search, {})
--vim.keymap.set('n', '<leader>b', nvim_traveller_rs.buffer_search, {})

--vim.keymap.set('n', '<leader>b', traveller_buffers.buffers, {})
