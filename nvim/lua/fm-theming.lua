local fmGlobals = require("fm-globals")

local M = {}

function M.add_theming(state)
    M.hlDirectoryGroup = "FmDirName"
    M.hlDirOptions = {
        --bg = "#ff0000",
        fg = "#F0E68C"
    }
    --M.hlOptions = {
        ----bg = "#ff0000",
        --fg = "#F0E68C"
    --}

    vim.api.nvim_win_set_option(state.win_id, 'winhighlight', 'NormalFloat:Normal,FloatBorder:Normal')
    state.ns_id = vim.api.nvim_create_namespace("FmTheming")

    vim.api.nvim_win_set_hl_ns(state.win_id, state.ns_id)

    vim.api.nvim_set_hl(state.ns_id, 'Normal', {})
    vim.api.nvim_set_hl(state.ns_id, 'FloatBorder', {})
    vim.api.nvim_set_hl(state.ns_id, M.hlDirectoryGroup, M.hlDirOptions)
end

function M.theme_buffer_content(state)
    for i, buf_dir_name in ipairs(state.buf_content) do
        if fmGlobals.is_item_directory(buf_dir_name) then
            vim.api.nvim_buf_add_highlight(state.buf_id, state.ns_id, M.hlDirectoryGroup, i - 1, 0, -1)
        else
            vim.api.nvim_buf_add_highlight(state.buf_id, state.ns_id, 'Normal', i - 1, 0, -1)
        end
    end
end

return M
