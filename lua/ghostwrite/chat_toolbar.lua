local Popup = require("nui.popup")
local M = {}

function M.create(chat_panel)
	local toolbar_popup = Popup({
		size = {
			width = chat_panel.width,
			height = chat_panel.output_height,
		},
		enter = false,
		focusable = true,
		buf_options = { bufhidden = "hide" },
		win_options = {
			winblend = 10,
		},
	})

	return toolbar_popup
end

return M
