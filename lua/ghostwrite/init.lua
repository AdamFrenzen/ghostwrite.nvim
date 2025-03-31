local M = {}

function M.setup()
	-- Define a Neovim command users can run
	vim.api.nvim_create_user_command("GhostwritePopup", M.open_popup, {})
end

function M.open_popup()
	-- Create a temporary buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set some lines in the buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"👻 Hello from ghostwrite!",
		"This is your AI assistant speaking...",
		"",
		"Press <Esc> to close this window.",
	})

	-- Define floating window layout
	local width = 50
	local height = 5
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	}

	-- Open the window
	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Optional: Close it on <Esc>
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>bd!<CR>", { nowait = true, noremap = true, silent = true })
end

return M
