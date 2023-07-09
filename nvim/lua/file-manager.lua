local path = require("plenary.path")
--local user_win = vim.api.nvim_get_current_win()
-- TODO remember position row position in buffer when navigating

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function debug(val)
    print(vim.inspect(val))
end

local function round(num)
    local fraction = num % 1
    if 0.5 < fraction then
        return math.ceil(num)
    else
        return math.floor(num)
    end
end


local function getBufferContent(dir_path)
    local buf_content = {}

    for item in io.popen("ls -pa " .. dir_path):lines() do
        if item ~= "./" and item ~= "../" then
            table.insert(buf_content, item)
        end
    end

    return buf_content
end

local function isItemDirectory(item)
    local ending = "/" -- TODO windows variant
    return item:sub(- #ending) == ending
end

-- Opens the navigation
local function openNavigation()
    local state = {
        buf = vim.api.nvim_create_buf(false, true),
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

    local function setBufferContent(dir)
        assert(isItemDirectory(dir), "Passed path is not a directory")

        state.dir_path = dir
        state.buf_content = getBufferContent(dir)

        vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(state.buf, 0, -1, true, state.buf_content)
        vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
    end

    local function closeNavigation()
        if state.is_open then
            vim.api.nvim_win_close(state.win_id, false)
            state.is_open = false
        end
    end

    local function setWindowCursor()
        for i, buf_dir_name in ipairs(state.buf_content) do
            for _, his_event in pairs(state.history) do
                if buf_dir_name == his_event.next_dir_name then
                    --debug(k)
                    vim.api.nvim_win_set_cursor(state.win_id, { i, 0 })
                    return
                end
            end
        end
    end

    local function actionOnItem(cmd_str)
        local cursor = vim.api.nvim_win_get_cursor(state.win_id)
        local item = state.buf_content[cursor[1]]

        if isItemDirectory(item) then
            if cmd_str == cmd.open then
                setBufferContent(state.dir_path .. item)
                setWindowCursor()
            end
        else
            local file_rel = path:new(state.dir_path .. item):make_relative()
            closeNavigation()
            vim.cmd(cmd_str .. ' ' .. file_rel)
        end
    end

    local function getDirectoryPath(filepath)
        if state.os == 'Windows' then
            return filepath:match("(.*\\)")
        else
            return filepath:match("(.*/)")
        end
    end

    local function navigateToParent()
        -- aanpassen aan current 
        local cursor = vim.api.nvim_win_get_cursor(state.win_id)
        local current_dir_abs = path:new(state.dir_path):absolute()

        if current_dir_abs == "/" then
            return
        end

        local parent_dir_abs = path:new(current_dir_abs):parent():absolute()
        local next_dir_name
        --local next_dir_name = state.buf_content[cursor[1]]

        if parent_dir_abs ~= "/" then
            parent_dir_abs = parent_dir_abs .. "/"
            next_dir_name = current_dir_abs:gsub("%" .. parent_dir_abs, "")
        else
            next_dir_name = current_dir_abs:sub(2)
        end

        local function getHistoryIndex()
            for i,v in ipairs(state.history) do
                if v.parent_dir_abs == parent_dir_abs then
                    return i
                end
            end
            return -1
        end

        local his_index = getHistoryIndex()

        if his_index == -1 then
            table.insert(state.history, {
                parent_dir_abs = parent_dir_abs,
                next_dir_name = next_dir_name,
            })
        else
            state.history[his_index].next_dir_name = next_dir_name
        end

        debug(dump(next_dir_name))

        setBufferContent(parent_dir_abs)
        setWindowCursor()
    end

    local function init()
        -- Get the current buffer directory
        local current_file = vim.api.nvim_buf_get_name(0)

        if current_file ~= "" then
            -- TODO create function that fills table based on OS
            -- (windows) opt.seperator = "\", (linux) opt.seperator = "/"

            local file_dir = getDirectoryPath(current_file)
            setBufferContent(file_dir)
        else
            setBufferContent("./")
        end

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

        state.win_id = vim.api.nvim_open_win(state.buf, true, options)
        state.is_open = true;

        vim.api.nvim_win_set_option(state.win_id, 'winhighlight', 'NormalFloat:Normal,FloatBorder:Normal')

        local buffer_options = { silent = true, buffer = state.buf }
        vim.keymap.set('n', 'q', closeNavigation, buffer_options)
        vim.keymap.set('n', '<Cr>', function() actionOnItem(cmd.open) end, buffer_options)
        vim.keymap.set('n', '<Right>', function() actionOnItem(cmd.open) end, buffer_options)
        vim.keymap.set('n', 'v', function() actionOnItem(cmd.vSplit) end, buffer_options)
        vim.keymap.set('n', 'h', function() actionOnItem(cmd.hSplit) end, buffer_options)
        vim.keymap.set('n', 't', function() actionOnItem(cmd.openTab) end, buffer_options)
        vim.keymap.set('n', '<Left>', navigateToParent, buffer_options)
    end

    init()
end

vim.keymap.set('n', '<leader>o', openNavigation, {})
