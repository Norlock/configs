local fmTheming = require("fm-theming")
local fmGlobals = require("fm-globals")
local path = require("plenary.path")

local function round(num)
    local fraction = num % 1
    if 0.5 < fraction then
        return math.ceil(num)
    else
        return math.floor(num)
    end
end

local function get_buffer_content(dir_path)
    local buf_content = {}

    for item in io.popen("ls -pa " .. dir_path):lines() do
        if item ~= "./" and item ~= "../" then
            table.insert(buf_content, item)
        end
    end

    return buf_content
end

-- Opens the navigation
local function open_navigation()
    local state = {
        buf_id = vim.api.nvim_create_buf(false, true),
        is_open = false,
        os = vim.loop.os_uname().sysname,
        history = {},
    }

    local cmd = {
        open = 'e',
        openTab = 'tabe',
        vSplit = 'vsplit',
        hSplit = 'split',
    }

    local function set_buffer_content(dir)
        assert(fmGlobals.is_item_directory(dir), "Passed path is not a directory")

        state.dir_path = dir
        state.buf_content = get_buffer_content(dir)

        vim.api.nvim_buf_set_option(state.buf_id, 'modifiable', true)
        vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, true, state.buf_content)
        vim.api.nvim_buf_set_option(state.buf_id, 'modifiable', false)

        fmTheming.theme_buffer_content(state)
    end

    local function close_navigation()
        if state.is_open then
            vim.cmd([[set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20]])
            vim.api.nvim_win_close(state.win_id, false)
            state.is_open = false
        end
    end

    local function set_window_cursor()
        for i, buf_dir_name in ipairs(state.buf_content) do
            for _, his_event in pairs(state.history) do
                if buf_dir_name == his_event.item_name then
                    vim.api.nvim_win_set_cursor(state.win_id, { i, 0 })
                    return
                end
            end
        end
        vim.api.nvim_win_set_cursor(state.win_id, { 1, 0 })
    end

    local function action_on_item(cmd_str)
        local cursor = vim.api.nvim_win_get_cursor(state.win_id)
        local item = state.buf_content[cursor[1]]

        if fmGlobals.is_item_directory(item) then
            if cmd_str == cmd.open then
                set_buffer_content(state.dir_path .. item)
                set_window_cursor()
            end
        else
            local file_rel = path:new(state.dir_path .. item):make_relative()
            close_navigation()
            vim.cmd(cmd_str .. ' ' .. file_rel)
        end
    end

    local function get_directory_path(filepath)
        if state.os == 'Windows' then
            return filepath:match("(.*\\)")
        else
            return filepath:match("(.*/)")
        end
    end

    local function navigate_to_parent()
        if state.dir_path == "/" then
            return
        end

        local function create_event(dir_abs, item_name)
            return {
                dir_abs = dir_abs,
                item_name = item_name,
            }
        end

        local function get_current_event()
            local cursor = vim.api.nvim_win_get_cursor(state.win_id)
            local item_name = state.buf_content[cursor[1]]

            return create_event(state.dir_path, item_name)
        end

        local function get_parent_event()
            local parts = fmGlobals.split(state.dir_path, "/")
            local item_name = table.remove(parts, #parts)

            local dir_abs = "/"
            for _, value in ipairs(parts) do
                dir_abs = dir_abs .. value .. "/"
            end

            return create_event(dir_abs, item_name .. "/")
        end

        local function get_history_index(cmp_path)
            for i, v in ipairs(state.history) do
                if v.dir_abs == cmp_path then
                    return i
                end
            end
            return -1
        end

        local function update_history_event(event)
            local his_index = get_history_index(event.dir_abs)

            if his_index == -1 then
                table.insert(state.history, event)
            else
                state.history[his_index].item_name = event.item_name
            end
        end

        local current_event = get_current_event()
        local parent_event = get_parent_event()

        update_history_event(current_event)
        update_history_event(parent_event)

        set_buffer_content(parent_event.dir_abs)
        set_window_cursor()

        fmGlobals.debug(state.history)
    end

    local function init()
        local ui = vim.api.nvim_list_uis()[1]

        local width = round(ui.width * 0.9)
        local height = round(ui.height * 0.8)

        local options = {
            relative = 'editor',
            width = width,
            height = height,
            col = (ui.width - width) * 0.5,
            row = (ui.height - height) * 0.2,
            anchor = 'NW',
            style = 'minimal',
            border = 'rounded',
            title = 'File manager',
            title_pos = 'center',
        }

        state.win_id = vim.api.nvim_open_win(state.buf_id, true, options)
        state.is_open = true;

        fmTheming.add_theming(state)

        local buffer_options = { silent = true, buffer = state.buf_id }
        vim.keymap.set('n', 'q', close_navigation, buffer_options)
        vim.keymap.set('n', '<Cr>', function() action_on_item(cmd.open) end, buffer_options)
        vim.keymap.set('n', '<Right>', function() action_on_item(cmd.open) end, buffer_options)
        vim.keymap.set('n', 'v', function() action_on_item(cmd.vSplit) end, buffer_options)
        vim.keymap.set('n', 'h', function() action_on_item(cmd.hSplit) end, buffer_options)
        vim.keymap.set('n', 't', function() action_on_item(cmd.openTab) end, buffer_options)
        vim.keymap.set('n', '<Left>', navigate_to_parent, buffer_options)

        -- Get the current buffer directory
        local current_file = vim.api.nvim_buf_get_name(0)

        fmGlobals.debug(current_file);
        if current_file ~= "" then
            -- TODO create function that fills table based on OS
            -- (windows) opt.seperator = "\", (linux) opt.seperator = "/"
            local file_dir = get_directory_path(current_file)
            set_buffer_content(path:new(file_dir):absolute() .. "/")
        else
            set_buffer_content(path:new("./"):absolute() .. "/")
        end
    end

    init()
end

vim.keymap.set('n', '<leader>o', open_navigation, {})
