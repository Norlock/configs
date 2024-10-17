require('plugins')
require('plugin-config')
require('keymaps')
require('themes')

vim.o.updatetime = 300
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.splitright = true -- Splits pane to the right
vim.o.splitbelow = true -- Splits pane below
vim.o.swapfile = false
vim.o.scrolloff = 3
--vim.o.textwidth = 120
vim.o.formatoptions = "tq"
vim.o.smartcase = true
vim.o.ignorecase = true

-- Show diagnostics in a pop-up window on hover
vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        underline = false,
        signs = true,
    }
)

vim.filetype.add({ extension = { wgsl = "wgsl" } })
