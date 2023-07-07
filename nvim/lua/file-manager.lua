local plenary = require("plenary")
local os = vim.loop.os_uname().sysname
local is_open = false
local user_win = vim.api.nvim_get_current_win()
local win

-- TODO create function that fills table based on OS
-- (windows) opt.seperator = "\", (linux) opt.seperator = "/"
local function getDirectory(filepath)
    if os == 'Windows' then
        return filepath:match("(.*\\)")
    else
        return filepath:match("(.*/)")
    end
end

local function getBufferContent(dir_path)
    local buf_content = {}

    for item in io.popen("ls -p " .. dir_path):lines() do
        table.insert(buf_content, item)
    end

    return buf_content
end

local function itemIsDirectory(item)
    local ending = "/" -- TODO windows variant
    return item:sub(- #ending) == ending
end

local function closeNavigation()
    if is_open then
        vim.api.nvim_win_close(win, false)
        is_open = false
    end
end

-- Opens the navigation
local function openNavigation()
    local ui = vim.api.nvim_list_uis()[1]

    local function round(num)
        local fraction = num % 1
        if 0.5 < fraction then
            return math.ceil(num)
        else
            return math.floor(num)
        end
    end

    local width = round(ui.width * 0.9)
    local height = round(ui.height * 0.8)

    local buf = vim.api.nvim_create_buf(false, true)
    local buf_content, dir_path

    local function setBufferContent(dir)
        dir_path = dir
        buf_content = getBufferContent(dir_path)
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, buf_content)
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end

    -- Get the current buffer directory
    local current_file = vim.api.nvim_buf_get_name(0)
    print(current_file)

    if current_file ~= "" then
        local path = getDirectory(current_file)
        setBufferContent(path)
    else
        setBufferContent("./")
    end

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

    win = vim.api.nvim_open_win(buf, true, options)
    is_open = true;

    vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal,FloatBorder:Normal')

    local function openFile(cmd)
        local cursor = vim.api.nvim_win_get_cursor(win)
        local item = buf_content[cursor[1]]

        if itemIsDirectory(item) then
           -- TODO
           print("is DIR " .. dir_path .. item)
           setBufferContent(dir_path .. item)
        else
            local file_rel = plenary.path:new(dir_path .. item):make_relative()

            --print(vim.inspect(file_rel))
            closeNavigation()
            vim.cmd(cmd .. ' ' .. file_rel)
        end
    end

    local buffer_options = { silent = true, buffer = buf }
    vim.keymap.set('n', 'q', closeNavigation, buffer_options)
    vim.keymap.set('n', '<Cr>', function() openFile('e') end, buffer_options)
    vim.keymap.set('n', 't', function() openFile('tabe') end, buffer_options)
    vim.keymap.set('n', 'v', function() openFile('vsplit') end, buffer_options)
    vim.keymap.set('n', 'h', function() openFile('split') end, buffer_options)
end

vim.keymap.set('n', '<leader>o', openNavigation, {})
