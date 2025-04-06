local config = require("ghostwrite.config").get()
local popup = require("ghostwrite.inline.popup")
local M = {}

function M.get_user_input(context) -- optional context
	local popup_position = popup.get_popup_position()
	local user_popup = popup.open_inline_popup({
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
		M.send_user_input(input, context)
	end

	user_popup:map("n", "o", ignore_key, config.default_bind_opts)
	user_popup:map("n", "O", ignore_key, config.default_bind_opts)
	user_popup:map("n", "<Esc>", close, config.default_bind_opts)
	user_popup:map("i", "<CR>", send, config.default_bind_opts)
end

function M.send_user_input(prompt, context)
	if not context then
		context = require("ghostwrite.utils").get_inline_context() -- cursor line, file, etc.
	end

	M.receive_ai_output(prompt)
end

-- function M.loading_spinner

function M.receive_ai_output(prompt)
	local lines = {
		" " .. prompt,
		"󰊠 `print(data)` is displaying data",
	}
	local count = #lines

	local popup_position = popup.get_popup_position()
	local response_popup = popup.open_inline_popup({
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
