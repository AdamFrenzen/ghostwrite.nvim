local Popup = require("nui.popup")
local M = {}

local function get_text_start_col()
	local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
	return (wininfo and wininfo[1] and wininfo[1].textoff) or 0
end

function M.open()
	local cursor_line = vim.fn.winline()
	local row = math.max(0, cursor_line - 3)
	local col_offset = get_text_start_col()

	local ai_response -- forward declare

	local function user_input()
		local popup = Popup({
			enter = true,
			focusable = true,
			border = {
				style = "rounded",
				text = {
					top = " inline-ghostwrite ",
					top_align = "left",
				},
			},
			position = {
				row = row,
				col = col_offset,
				relative = "win",
			},
			size = {
				width = 80,
				height = 1,
			},
			buf_options = {
				modifiable = true,
				readonly = false,
			},
		})

		popup:mount()

		vim.schedule(function()
			vim.cmd("startinsert")
		end)

		vim.keymap.set("n", "o", "<Nop>", { buffer = popup.bufnr, noremap = true })
		vim.keymap.set("n", "O", "<Nop>", { buffer = popup.bufnr, noremap = true })

		popup:map("n", "<Esc>", function()
			popup:unmount()
		end, { noremap = true })

		vim.keymap.set("i", "<CR>", function()
			local line = vim.api.nvim_buf_get_lines(popup.bufnr, 0, 1, false)[1] or ""
			popup:unmount()
			ai_response(line)
		end, { noremap = true })
	end

	user_input()

	ai_response = function(line)
		local popup = Popup({
			enter = true,
			focusable = true,
			border = {
				style = "rounded",
				text = {
					top = " inline-ghostwrite ",
					top_align = "left",
				},
			},
			position = {
				row = row,
				col = col_offset,
				relative = "win",
			},
			size = {
				width = 80,
				height = 1,
			},
			buf_options = {
				modifiable = true,
				readonly = false,
			},
		})

		popup:mount()

		vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
			"👤 " .. line,
			"",
			"🤖 AI response...",
			"[a] Apply  [p] Promote  [x] Dismiss",
		})
	end
end

return M
