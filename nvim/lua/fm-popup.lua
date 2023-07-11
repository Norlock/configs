local fmGlobals = require("fm-globals")
local fmTheming = require("fm-theming")

local M = {}

function M.create_dir_popup(fmMod)
    -- action popup state
    local state = {
        buf_id = vim.api.nvim_create_buf(false, true),
        buf_content = "",
        is_open = false,
    }

    local function close_navigation()
        if state.is_open then
            vim.cmd('stopinsert')
            vim.api.nvim_win_close(state.win_id, false)
            state.is_open = false
        end
    end

    local function create_dir()
        local line = vim.api.nvim_buf_get_lines(state.buf_id, 0, 1, false)
        local parts = fmGlobals.split(line[1], " ")

        local cmd = "!mkdir"

        for _, item in ipairs(parts) do
            cmd = cmd .. " " .. fmMod.get_dir_path() .. item
        end

        fmGlobals.debug(cmd)
        vim.cmd(cmd)

        fmMod.reload()
        close_navigation()
    end

    local function init()
        local ui = vim.api.nvim_list_uis()[1]
        local width = fmGlobals.round(ui.width * 0.6)
        local height = fmGlobals.round(1)

        local options = {
            relative = 'editor',
            width = width,
            height = height,
            col = (ui.width - width) * 0.5,
            row = (ui.height - height) * 0.2,
            anchor = 'NW',
            style = 'minimal',
            border = 'rounded',
            title = ' mkdir ',
            title_pos = 'center',
        }

        state.win_id = vim.api.nvim_open_win(state.buf_id, true, options)
        state.is_open = true;

        local buffer_options = { silent = true, buffer = state.buf_id }
        vim.keymap.set('i', '<Esc>', function () close_navigation(state) end, buffer_options)
        vim.keymap.set('i', '<Cr>', create_dir, buffer_options)

        fmTheming.add_theming(state)
        vim.cmd('startinsert')
    end

    init()
end

return M
