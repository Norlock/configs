require('plugins')
require('plugin-config')
require('keymaps')
require('themes')

vim.o.updatetime = 300
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.tabstop = 4
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
_G.LspDiagnosticsPopupHandler = function()
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

    -- Show the popup diagnostics window,
    -- but only once for the current cursor location (unless moved afterwards).
    if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
        vim.w.lsp_diagnostics_last_cursor = current_cursor
        vim.diagnostic.open_float(0, { scope = "cursor" })
    end
end
vim.cmd [[
augroup LSPDiagnosticsOnHover
  autocmd!
  autocmd CursorHold *   lua _G.LspDiagnosticsPopupHandler()
augroup END
]]

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        underline = false,
        signs = true,
    }
)

vim.filetype.add({ extension = { wgsl = "wgsl" } })
