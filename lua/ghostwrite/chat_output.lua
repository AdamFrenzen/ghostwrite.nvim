local Popup = require("nui.popup")
local M = {}

function M.create(chat_panel)
	local output_popup = Popup({
		size = {
			width = chat_panel.width,
			height = chat_panel.output_height,
		},
		border = {
			style = "rounded",
			text = {
				top = " 󰊠 ghostwrite-chat ",
				top_align = "left",
				bottom = " [↑] [Tab] [↓] ",
				bottom_align = "center",
			},
		},
		enter = false,
		focusable = true,
		buf_options = { bufhidden = "hide" },
		win_options = {
			winblend = 10,
		},
	})

	vim.bo[output_popup.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(output_popup.bufnr, -1, -1, false, { " 󰊠 wuz here " })
	vim.bo[output_popup.bufnr].modifiable = false

	return output_popup
end

return M
