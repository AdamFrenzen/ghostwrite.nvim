local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local M = {}

function M.open()
	local default_bind_opts = { noremap = true, silent = true, nowait = true }

	-- Define the panel width
	local panel_width = 60

	-- Create the chat panel popup
	local chat_panel = Popup({
		relative = "editor", -- relative to the entire Neovim window
		position = {
			row = 1,
			col = vim.o.columns - panel_width, -- position at the right edge
		},
		size = {
			width = panel_width,
			height = vim.o.lines - 3, -- leave some room for command/status lines
		},
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = " 󰊠 ghostwrite-chat ",
				top_align = "left",
			},
		},
		win_options = {
			winblend = 10,
			-- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	})
	chat_panel:mount()

	-- Optional: Refresh the panel on VimResized event to reposition if the window changes size.
	chat_panel:on(event.VimResized, function()
		chat_panel:unmount()
		chat_panel:mount()
	end)
end

return M
