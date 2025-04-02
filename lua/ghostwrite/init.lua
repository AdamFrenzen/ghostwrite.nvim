local M = {}
local Popup = require("nui.popup")

-- Create user commands
function M.setup()
	vim.api.nvim_create_user_command("GhostwriteInline", M.open_popup, {})
	vim.api.nvim_create_user_command("ReloadGhostwrite", ReloadGhostwrite, {})

	vim.keymap.set("n", "<leader>Gi", "<cmd>GhostwriteInline<cr>", {
		desc = "Ghostwrite: Inline Chat",
		noremap = true,
		silent = true,
	})
end

-- Development: hot-reload the module
function _G.ReloadGhostwrite()
	require("plenary.reload").reload_module("ghostwrite")
	require("ghostwrite").setup()
	print("🔄 Ghostwrite reloaded!")
end

-- Utility: Get column offset after line numbers and signs
local function get_text_start_col()
	local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
	return (wininfo and wininfo[1] and wininfo[1].textoff) or 0
end

-- Main popup logic
function M.open_popup()
	local cursor_line = vim.fn.winline() -- row in window, 1-based
	local row = math.max(0, cursor_line - 3) -- float slightly above cursor
	local col_offset = get_text_start_col()

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

	-- Enter insert mode after mount
	vim.schedule(function()
		vim.cmd("startinsert")
	end)

	-- Disable newlines
	vim.keymap.set("n", "o", "<Nop>", { buffer = popup.bufnr, noremap = true })
	vim.keymap.set("n", "O", "<Nop>", { buffer = popup.bufnr, noremap = true })

	-- Handle <Enter>: print input, then close popup
	vim.keymap.set("i", "<CR>", function()
		local line = vim.api.nvim_buf_get_lines(popup.bufnr, 0, 1, false)[1] or ""
		print("💬", line)
		popup:unmount()
	end, { buffer = popup.bufnr, noremap = true })

	-- Close on <Esc>
	popup:map("n", "<Esc>", function()
		popup:unmount()
	end, { noremap = true })
end

return M
