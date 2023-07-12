local fmGlobals = require("fm-globals")
local fmTheming = require("fm-theming")

local M = {}

local function create_simple_state()
    return {
        buf_id = vim.api.nvim_create_buf(false, true),
        buf_content = {},
        is_open = false,
    }
end

local function create_cmd_popup(dir_path, reload, cmd_options)
    local state = create_simple_state()

    local function close_navigation()
        if state.is_open then
            vim.cmd('stopinsert')
            vim.api.nvim_win_close(state.win_id, false)
            state.is_open = false
        end
    end

    local function execute_create()
        local user_input = vim.api.nvim_buf_get_lines(state.buf_id, 0, 1, false)
        local parts = fmGlobals.split(user_input[1], " ")

        local cmd = cmd_options.sh_cmd

        for _, item in ipairs(parts) do
            cmd = cmd .. " " .. dir_path .. item
        end

        local output = vim.fn.systemlist(cmd)

        reload()
        close_navigation()

        if #output ~= 0 then
            fmGlobals.debug(output)
            M.create_info_popup(output, state.win_id, 'Command failed (Esc / q)')
        end
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
            title_pos = 'center',
            noautocmd = true,
        }

        state.win_id = vim.api.nvim_open_win(state.buf_id, true, win_options)
        state.is_open = true;
        fmTheming.add_theming(state)

        local buffer_options = { silent = true, buffer = state.buf_id }
        vim.keymap.set('i', '<Esc>', close_navigation, buffer_options)
        vim.keymap.set('i', '<Cr>', execute_create, buffer_options)

        vim.cmd('startinsert')
    end

    init()
end

function M.create_delete_item_popup(buf_content, parent_win_id)
    local popup = M.create_info_popup(buf_content, parent_win_id,
        'Confirm (Enter), cancel (Esc / q)')

    fmGlobals.debug(popup)
    return popup
end

function M.create_file_popup(dir_path, reload)
    local options = {
        title = ' touch ',
        sh_cmd = 'touch'
    }

    create_cmd_popup(dir_path, reload, options)
end

function M.create_dir_popup(dir_path, reload)
    local options = {
        title = ' mkdir ',
        sh_cmd = 'mkdir'
    }

    create_cmd_popup(dir_path, reload, options)
end

-- options = {
--    buf_content, parent_win_id, title
-- }
function M.create_info_popup(buf_content, parent_win_id, title)
    local popup = {}
    local state = create_simple_state()
    popup.state = state

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
        local win_width = vim.api.nvim_win_get_width(0)
        local win_height = vim.api.nvim_win_get_height(0)
        local pos = vim.api.nvim_win_get_position(0)
        local height = fmGlobals.round(#buf_content)

        local win_options = {
            relative = 'win',
            win = parent_win_id,
            width = win_width,
            height = height,
            row = pos[1] + win_height,
            col = -1,
            anchor = 'SW',
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

    init()

    function popup.set_keymap(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, state.buffer_options)
    end

    return popup
end

return M
