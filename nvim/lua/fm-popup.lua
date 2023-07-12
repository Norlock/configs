local fmGlobals = require("fm-globals")
local fmTheming = require("fm-theming")

local M = {}

local function init_popup_module()
    local buf_id = vim.api.nvim_create_buf(false, true)

    local state = {
        buf_id = buf_id,
        buf_content = {},
        is_open = false,
        buffer_options = { silent = true, buffer = buf_id }
    }

    local popup = { state }

    return popup, state
end

local function create_cmd_popup(dir_path, cmd_options)
    local popup, state = init_popup_module()

    function popup.close_navigation()
        if state.is_open then
            vim.cmd('stopinsert')
            vim.api.nvim_win_close(state.win_id, false)
            state.is_open = false
        end
    end

    function popup.create_sh_cmd()
        local user_input = vim.api.nvim_buf_get_lines(state.buf_id, 0, 1, false)
        local parts = fmGlobals.split(user_input[1], " ")

        local cmd = cmd_options.sh_cmd

        for _, item in ipairs(parts) do
            cmd = cmd .. " " .. dir_path .. item
        end

        return cmd
    end

    local function init()
        local ui = vim.api.nvim_list_uis()[1]
        local width = fmGlobals.round(ui.width * 0.6)
        local height = fmGlobals.round(1)

        local win_options = {
            relative = 'editor',
            width = width,
            height = height,
            col = (ui.width - width) * 0.5,
            row = (ui.height - height) * 0.2,
            anchor = 'NW',
            style = 'minimal',
            border = 'rounded',
            title = cmd_options.title,
            title_pos = 'left',
            noautocmd = true,
        }

        state.win_id = vim.api.nvim_open_win(state.buf_id, true, win_options)
        state.is_open = true;
        fmTheming.add_theming(state)

        vim.keymap.set('i', '<Esc>', popup.close_navigation, state.buffer_options)

        vim.cmd('startinsert')
    end

    function popup.set_keymap(lhs, rhs)
        vim.keymap.set('i', lhs, rhs, state.buffer_options)
    end

    init()

    return popup
end

function M.create_delete_item_popup(buf_content, parent_win_id)
    return M.create_info_popup(buf_content, parent_win_id,
        'Confirm (Enter), cancel (Esc / q)')
end

function M.create_file_popup(dir_path)
    local options = {
        title = ' Touch (separate by space) ',
        sh_cmd = 'touch'
    }

    return create_cmd_popup(dir_path, options)
end

function M.create_dir_popup(dir_path)
    local options = {
        title = ' Mkdir (separate by space) ',
        sh_cmd = 'mkdir'
    }

    return create_cmd_popup(dir_path, options)
end

function M.create_info_popup(buf_content, related_win_id, title)
    local popup, state = init_popup_module()

    function popup.close_navigation()
        if state.is_open then
            vim.api.nvim_win_close(state.win_id, false)
            state.is_open = false
        end
    end

    function popup.set_buffer_content()
        state.buf_content = buf_content

        vim.api.nvim_buf_set_option(state.buf_id, 'modifiable', true)
        vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, true, state.buf_content)
        vim.api.nvim_buf_set_option(state.buf_id, 'modifiable', false)

        fmTheming.theme_buffer_content(state)
    end

    local function init()
        local win_width = vim.api.nvim_win_get_width(related_win_id)
        local win_height = vim.api.nvim_win_get_height(related_win_id)
        local height = fmGlobals.round(#buf_content)

        local win_options = {
            relative = 'win',
            win = related_win_id,
            width = win_width,
            height = height,
            row = win_height - height - 1,
            col = -1,
            anchor = 'NW',
            style = 'minimal',
            border = 'single',
            title = ' ' .. title .. ' ',
            title_pos = "right",
            noautocmd = true,
        }

        state.win_id = vim.api.nvim_open_win(state.buf_id, true, win_options)
        state.is_open = true;
        state.buffer_options = { silent = true, buffer = state.buf_id }

        vim.keymap.set('n', '<Esc>', popup.close_navigation, state.buffer_options)
        vim.keymap.set('n', 'q', popup.close_navigation, state.buffer_options)

        popup.set_buffer_content()

        fmTheming.add_error_theming(state)
    end

    function popup.set_keymap(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, state.buffer_options)
    end

    init()

    return popup
end

return M
