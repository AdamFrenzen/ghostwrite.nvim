local Popup = require("nui.popup")
local M = {}

function M.get_position()
	local function get_text_start_col()
		local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
		if wininfo and wininfo[1] and wininfo[1].textoff then
			return wininfo[1].textoff
		end
		return 0 -- fallback when textoff is unavailable
	end

	local cursor_line = vim.fn.winline()

	return {
		col_offset = get_text_start_col(), -- ← includes line numbers, signs, folds
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
				bottom = opts.bottom or "",
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
			bufhidden = "wipe",
		},
	})
end

return M
