local fmGlobals = require("fm-globals")

local M = {}

function M.add_theming(state)
    local directoryColor = {
        --bg = "#ff0000",
        fg = "#F0E68C"
    }

    state.ns_id = vim.api.nvim_create_namespace("FmTheming")

    vim.api.nvim_win_set_hl_ns(state.win_id, state.ns_id)

    vim.api.nvim_set_hl(state.ns_id, 'Normal', {})
    vim.api.nvim_set_hl(state.ns_id, 'FloatBorder', {})
    --vim.api.nvim_set_hl(ns_id, 'Error', { fg = "#ffffff", undercurl = true })
    --vim.api.nvim_set_hl(ns_id, 'Cursor', { reverse = true })

    state.hlDirectoryGroup = "FmDirName"

    vim.api.nvim_set_hl(state.ns_id, state.hlDirectoryGroup, directoryColor)
    --vim.api.nvim_buf_add_highlight(buf_id, ns_id, M.hlDirectoryGroup, 0, 0, -1)
end

function M.theme_buffer_content(state)
    vim.api.nvim_buf_clear_namespace(state.buf_id, state.ns_id, 1, #state.buf_content)

    for i, buf_dir_name in ipairs(state.buf_content) do
        if fmGlobals.is_item_directory(buf_dir_name) then
            vim.api.nvim_buf_add_highlight(state.buf_id, state.ns_id, state.hlDirectoryGroup, i - 1, 0, -1)
        else
            vim.api.nvim_buf_add_highlight(state.buf_id, state.ns_id, 'Normal', i - 1, 0, -1)
        end
    end
end

return M
