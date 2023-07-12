local fmGlobals = require("fm-globals")

local theming = {
    ns_id = vim.api.nvim_create_namespace("FmTheming"),
    popup_ns_id = vim.api.nvim_create_namespace("FmInfoTheming"),
    help_ns_id = vim.api.nvim_create_namespace("FmHelpTheming")
}

function theming.add_theming(state)
    vim.opt_local.cursorline = true

    vim.api.nvim_set_hl(theming.ns_id, 'Normal', {})
    vim.api.nvim_set_hl(theming.ns_id, 'FloatBorder', {})
    vim.api.nvim_set_hl(theming.ns_id, 'CursorLine', { bold = true })

    vim.api.nvim_win_set_hl_ns(state.win_id, theming.ns_id)
end

function theming.add_info_popup_theming(state)
    local hlBorder = {
        link = "Question",
    }

    vim.api.nvim_set_hl(theming.popup_ns_id, 'FloatBorder', hlBorder)
    vim.api.nvim_set_hl(theming.popup_ns_id, 'FloatTitle', hlBorder)
    vim.api.nvim_set_hl(theming.popup_ns_id, 'NormalFloat', { italic = true })

    vim.api.nvim_win_set_hl_ns(state.win_id, theming.popup_ns_id)
end

function theming.add_help_popup_theming(state)
    -- TODO
    vim.api.nvim_set_hl(theming.popup_ns_id, 'NormalFloat', {})

    vim.api.nvim_win_set_hl_ns(state.win_id, theming.popup_ns_id)
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
