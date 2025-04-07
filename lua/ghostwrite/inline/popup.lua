local Popup = require("nui.popup")
local M = {}

function M.get_position()
	-- Get the starting column of the text area (accounts for line numbers, signs, folds, etc.)
	local function get_text_start_col()
		local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
		if wininfo and wininfo[1] and wininfo[1].textoff then
			return wininfo[1].textoff
		end

		-- Fallback to start of window when textoff is unavailable
		return 0
	end

	local cursor_line = vim.fn.winline()

	-- Position the popup 3 lines above the cursor (1 line + top/bottom borders)
	return {
		col_offset = get_text_start_col(),
		row = math.max(0, cursor_line - 3),
	}
end

function M.open(opts)
	return Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = " 󰊠 ghostwrite-inline ",
				top_align = "left",
				bottom = opts.bottom_text or "",
				bottom_align = "right",
			},
		},
		position = {
			row = opts.row or 0,
			col = opts.col or 0,
			relative = "win",
		},
		size = {
			width = opts.width or 80,
			height = opts.height or 1,
		},
		buf_options = {
			modifiable = true,
			readonly = false,
			-- Remove the buffer
			bufhidden = "wipe",
		},
	})
end

return M
