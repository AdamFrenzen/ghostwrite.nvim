local config = require("ghostwrite.config").get()
local popup = require("ghostwrite.inline.popup")
local M = {}

-- Optional context (defaults to line under cursor if not provided)
function M.get_user_input(context)
	local popup_position = popup.get_position()
	local user_popup = popup.open({
		bottom_text = " [Enter] send [Esc] cancel ",
		row = popup_position.row,
		col = popup_position.col_offset,
		height = 1,
	})
	user_popup:mount()

	-- Delay entering insert mode until after the popup is mounted
	vim.schedule(function()
		vim.cmd("startinsert")
	end)

	-- No-op to suppress normal mode keybindings like 'o' and 'O' in the popup (prevent newline)
	local function noop_key() end

	-- Close the popup without submitting input (mapped to <Esc>)
	local function close()
		user_popup:unmount()
	end

	-- Submit the user's input and unmount the popup (mapped to <CR>)
	local function send()
		local input = vim.api.nvim_buf_get_lines(user_popup.bufnr, 0, 1, false)[1] or ""
		user_popup:unmount()

		M.send_user_input(input, context)
	end

	user_popup:map("n", "o", noop_key, config.default_keybind_opts)
	user_popup:map("n", "O", noop_key, config.default_keybind_opts)
	user_popup:map("n", "<Esc>", close, config.default_keybind_opts)
	user_popup:map("i", "<CR>", send, config.default_keybind_opts)
end

function M.send_user_input(prompt, context)
	if not context then
		context = require("ghostwrite.utils").get_inline_context()
	end

	-- Temporary mock response
	-- TODO: Send the prompt to the backend and have it open display_llm_output instead of here
	M.display_llm_output(prompt, "`print(data)` is displaying data")
end

-- TODO: Add spinner to show loading state before response arrives
-- function M.loading_spinner
-- end

function M.display_llm_output(prompt, response)
	local output = {
		" " .. prompt,
		"󰊠 " .. response,
	}
	local output_row_count = #output

	-- Create and mount a popup to display the LLM response
	local popup_position = popup.get_position()
	local response_popup = popup.open({
		bottom_text = " [y] accept  [n] dismiss  [→] move to chat ",
		row = popup_position.row - output_row_count + 1, -- Shift upward to fit all lines of the response above cursor
		col = popup_position.col_offset,
		height = output_row_count,
	})
	response_popup:mount()

	-- Write response into popup
	vim.bo[response_popup.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, output)
	vim.bo[response_popup.bufnr].modifiable = false

	-- Delay exiting insert mode to ensure the popup is mounted
	vim.defer_fn(function()
		vim.cmd("stopinsert")
	end, 10) -- Delay by 10ms

	-- Accept LLM suggestions and close popup
	local function accept()
		-- TODO: Accept the LLM-generated diff in the current buffer
		response_popup:unmount()
	end

	-- Close the popup without applying changes
	local function dismiss()
		-- TODO: Reject the LLM-generated diff in the current buffer
		response_popup:unmount()
	end

	-- Move the user input and the llm output message to the chat panel
	local function move_to_chat()
		--TODO: Move the prompt and LLM response to the chat penel
		-- response_popup.unmount()
	end

	response_popup:map("n", "y", accept, config.default_keybind_opts)
	response_popup:map("n", "n", dismiss, config.default_keybind_opts)
	response_popup:map("n", "<Right>", move_to_chat, config.default_keybind_opts)
	response_popup:map("n", "<Esc>", dismiss, config.default_keybind_opts)
end

return M
