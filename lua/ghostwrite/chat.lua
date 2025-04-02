local Popup = require("nui.popup")
local Layout = require("nui.layout")
local M = {}

function M.open()
	local panel_width = 60
	local panel_height = vim.o.lines - 3

	local output_height = math.floor(panel_height * 0.8)
	local input_height = panel_height - output_height

	local output_popup = Popup({
		size = {
			width = panel_width,
			height = output_height,
		},
		border = {
			style = "rounded",
			text = {
				top = " 󰊠 ghostwrite-chat ",
				top_align = "left",
			},
		},
		enter = false,
		focusable = false,
		win_options = {
			winblend = 10,
		},
	})

	-- Create the interactive input popup.
	local input_popup = Popup({
		size = {
			width = panel_width,
			height = input_height,
		},
		border = {
			style = "rounded",
			text = {
				bottom = " [Enter] send message ",
				bottom_align = "right",
			},
		},
		enter = true,
		focusable = true,
		win_options = {
			winblend = 10,
		},
	})

	local layout = Layout(
		{
			relative = "editor",
			position = {
				row = 1,
				col = vim.o.columns - panel_width, -- right side of the screen
			},
			size = {
				width = panel_width,
				height = panel_height,
			},
		},
		Layout.Box({
			Layout.Box(output_popup, { size = output_height }),
			Layout.Box(input_popup, { size = input_height }),
		}, { dir = "col" })
	)

	layout:mount()

	-- make output non modifiable
	vim.bo[output_popup.bufnr].modifiable = false

	-- enter in insert mode
	vim.schedule(function()
		vim.cmd("startinsert")
	end)

	-- start with the input pane focused
	local current_focus = 2

	-- toggle between output and input using Tab.
	local function toggle_focus()
		if current_focus == 1 then
			vim.api.nvim_set_current_win(input_popup.winid)
			current_focus = 2
		else
			vim.bo[output_popup.bufnr].modifiable = true
			vim.api.nvim_set_current_win(output_popup.winid)
			vim.bo[output_popup.bufnr].modifiable = false
			current_focus = 1
		end
	end

	local function close()
		layout:unmount()
	end

	output_popup:map("n", "<Tab>", toggle_focus, M.default_bind_opts)
	input_popup:map("n", "<Tab>", toggle_focus, M.default_bind_opts)
	output_popup:map("n", "<Esc>", close, M.default_bind_opts)
	input_popup:map("n", "<Esc>", close, M.default_bind_opts)
end

return M
