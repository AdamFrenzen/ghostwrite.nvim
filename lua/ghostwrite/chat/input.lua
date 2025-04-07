local Popup = require("nui.popup")
local M = {}

function M.create(chat_panel)
	local input_popup = Popup({
		size = {
			width = chat_panel.width,
			height = chat_panel.input_height,
		},
		border = {
			style = "rounded",
			text = {
				top = "  input ",
				top_align = "left",
				bottom = " [Enter] send [Esc] hide ",
				bottom_align = "right",
			},
		},
		enter = true,
		focusable = true,
		buf_options = { bufhidden = "hide" },
		win_options = {
			winblend = 10,
		},
	})

	return input_popup
end

return M
