local map = vim.keymap.set
local fzf = require("fzf-lua")

map("n", "<space>", "<nop>", { silent = true })
map("i", "jj", "<esc>", { silent = true })
map("n", "<c-s>", ":w<cr>", { silent = true })
map('n', '_', ':move -2<cr>', { silent = true })
map('n', '+', ':move +1<cr>', { silent = true })
map('n', '<a-o>', ':only<cr>', { silent = true })
map('n', '<esc>', ':nohls<cr>', { silent = true })

local function format()
    if vim.bo.filetype == 'svelte' 
        or vim.bo.filetype == 'typescript' 
        or vim.bo.filetype == 'javascript'
        or vim.bo.filetype == 'json' then
        local path = vim.fn.expand('%:p:h');
        local file = vim.fn.expand('%:p:t');

        vim.cmd(":write")
        vim.fn.system("cd " .. path .. " && npx prettier --write " .. file)
        vim.cmd(":e")
    else
        vim.lsp.buf.format()
    end
end

-- LSP
map('n', ',f', format, {})
map('n', ',r', vim.lsp.buf.rename, {})
map('n', ',q', vim.lsp.buf.code_action, {})
map('n', 'K', vim.lsp.buf.hover, {})
map('n', 'gd', fzf.lsp_definitions, {})
map('n', 'gi', vim.lsp.buf.implementation, {})
map('n', 'gr', fzf.lsp_references, {})

-- Fuzzy
map('n', "<leader>g", fzf.git_files, {})
map('n', "<leader>f", fzf.files, {})
map('n', "<leader>b", fzf.buffers, {})
map('n', "<leader>d", fzf.git_diff, {})
map('n', "<leader>a", fzf.live_grep_glob, {})

-- Diagnostics
map('n', '<A-d>', vim.diagnostic.setqflist, {})
map('n', '<A-down>', ':lnext<cr>', {})
map('n', '<A-up>', ':lprev<cr>', {})

-- File manager 
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

