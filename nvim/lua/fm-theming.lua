local fmGlobals = require("fm-globals")

local theming = {
    ns_id = vim.api.nvim_create_namespace("FmTheming"),
    error_ns_id = vim.api.nvim_create_namespace("FmErrorTheming")
}

function theming.add_theming(state)
    local hlCursorLine = {
        bold = true,
    }

    vim.opt_local.cursorline = true

    vim.api.nvim_set_hl(theming.ns_id, 'Normal', {})
    vim.api.nvim_set_hl(theming.ns_id, 'FloatBorder', {})
    vim.api.nvim_set_hl(theming.ns_id, 'CursorLine', hlCursorLine)

    vim.api.nvim_win_set_hl_ns(state.win_id, theming.ns_id)
end

function theming.add_error_theming(state)
    local hlOptions = {
        fg = "#f5f0f6",
        bg = "#cc2936",
        italic = true,
    }

    vim.api.nvim_set_hl(theming.error_ns_id, 'Normal', {})
    vim.api.nvim_set_hl(theming.error_ns_id, 'FloatBorder', {})
    vim.api.nvim_set_hl(theming.error_ns_id, 'Normal', hlOptions)

    vim.api.nvim_win_set_hl_ns(state.win_id, theming.error_ns_id)
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
