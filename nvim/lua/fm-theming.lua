local fmGlobals = require("fm-globals")

local theming = {}

function theming.add_theming(state)
    theming.ns_id = vim.api.nvim_create_namespace("FmTheming")

    theming.hlDirOptions = {
        --bg = "#ff0000",
        fg = "#F0E68C",
    }

    theming.hlCursorLine = {
        fg = "#333333",
        bg = "#E1D67C",
    }

    vim.opt_local.cursorline = true

    vim.api.nvim_set_hl(theming.ns_id, 'Normal', {})
    vim.api.nvim_set_hl(theming.ns_id, 'FloatBorder', {})
    vim.api.nvim_set_hl(theming.ns_id, 'CursorLine', theming.hlCursorLine)

    vim.api.nvim_win_set_hl_ns(state.win_id, theming.ns_id)
    vim.cmd([[set guicursor=n:ver25]])
end

function theming.theme_buffer_content(state)
    vim.api.nvim_buf_clear_namespace(state.buf_id, -1, 1, -1)
    for i, buf_dir_name in ipairs(state.buf_content) do
        if fmGlobals.is_item_directory(buf_dir_name) then
            vim.api.nvim_buf_add_highlight(state.buf_id, theming.ns_id, "Directory", i - 1, 0, -1)
        end
    end
end

return theming
