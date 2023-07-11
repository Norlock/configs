local fmGlobals = require("fm-globals")
local fmTheming = require("fm-theming")

local function create_popup(dir_path, reload, cmd_options)
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

	local function execute()
		local line = vim.api.nvim_buf_get_lines(state.buf_id, 0, 1, false)
		local parts = fmGlobals.split(line[1], " ")

		local cmd = "!" .. cmd_options.sh_cmd

		for _, item in ipairs(parts) do
			cmd = cmd .. " " .. dir_path .. item
		end

		fmGlobals.debug(cmd)
		vim.cmd(cmd)

		reload()
		close_navigation()
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
		}

		state.win_id = vim.api.nvim_open_win(state.buf_id, true, win_options)
		state.is_open = true;

		local buffer_options = { silent = true, buffer = state.buf_id }
		vim.keymap.set('i', '<Esc>', close_navigation, buffer_options)
		vim.keymap.set('i', '<Cr>', execute, buffer_options)

		fmTheming.add_theming(state)
		vim.cmd('startinsert')
	end

	init()
end

local M = {}

function M.create_file_popup(dir_path, reload)
	local options = {
		title = ' touch ',
		sh_cmd = 'touch'
	}

	create_popup(dir_path, reload, options)
end

function M.create_dir_popup(dir_path, reload)
	local options = {
		title = ' mkdir ',
		sh_cmd = 'mkdir'
	}

	create_popup(dir_path, reload, options)
end

return M
