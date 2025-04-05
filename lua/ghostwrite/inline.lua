local config = require("ghostwrite.config").get()
local Popup = require("nui.popup")
local M = {}

function M.get_popup_position()
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

function M.open_inline_popup(opts)
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

function M.get_user_input()
	local popup_position = M.get_popup_position()
	local user_popup = M.open_inline_popup({
		bottom = " [Enter] send [Esc] cancel ",
		row = popup_position.row,
		col = popup_position.col_offset,
		height = 1,
	})
	user_popup:mount()

	-- enter in insert mode
	vim.schedule(function()
		vim.cmd("startinsert")
	end)

	local function ignore_key() end

	local function close()
		user_popup:unmount()
	end

	local function send()
		local input = vim.api.nvim_buf_get_lines(user_popup.bufnr, 0, 1, false)[1] or ""
		user_popup:unmount()
		M.send_user_input(input)
	end

	user_popup:map("n", "o", ignore_key, config.default_bind_opts)
	user_popup:map("n", "O", ignore_key, config.default_bind_opts)
	user_popup:map("n", "<Esc>", close, config.default_bind_opts)
	user_popup:map("i", "<CR>", send, config.default_bind_opts)
end

function M.send_user_input(prompt, context)
	M.recieve_ai_output(prompt)
end

function M.recieve_ai_output(prompt)
	local lines = {
		" " .. prompt,
		"󰊠 `print(data)` is displaying data",
	}
	local count = #lines

	local popup_position = M.get_popup_position()
	local response_popup = M.open_inline_popup({
		bottom = " [y] apply  [n] dismiss  [→] move to chat ",
		row = popup_position.row - count + 1,
		col = popup_position.col_offset,
		height = count,
	})
	response_popup:mount()

	-- write response into popup
	vim.bo[response_popup.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, lines)
	vim.bo[response_popup.bufnr].modifiable = false

	-- enter in normal mode
	vim.defer_fn(function()
		vim.cmd("stopinsert")
	end, 10) -- delay by 10ms

	local function apply()
		print("eventually ghostwrite will apply those suggestions")
		response_popup:unmount()
	end

	local function dismiss()
		response_popup:unmount()
	end

	response_popup:map("n", "y", apply, config.default_bind_opts)
	response_popup:map("n", "n", dismiss, config.default_bind_opts)
	response_popup:map("n", "<Esc>", dismiss, config.default_bind_opts)
end

return M
