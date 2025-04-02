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
	vim.keymap.set("n", "<leader>Gr", "<cmd>ReloadGhostwrite<cr>", {
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

	vim.keymap.set("i", "<CR>", function()
		local line = vim.api.nvim_buf_get_lines(popup.bufnr, 0, 1, false)[1] or ""

		-- Clear the input line (or keep it if you want to show it)
		vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
			"👤 " .. line,
			"", -- spacer line
		})

		-- Resize popup to fit response
		local response_lines = {
			"🤖 Sure! Here's what I did:",
			" - Removed the unused import.",
			" - Wrapped the call in a try/catch.",
		}

		local function append_line(i)
			if i > #response_lines then
				return
			end

			local current_lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
			table.insert(current_lines, response_lines[i])
			vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, current_lines)

			-- Dynamically grow popup
			vim.api.nvim_win_set_height(popup.winid, #current_lines)

			vim.defer_fn(function()
				append_line(i + 1)
			end, 100)
		end

		append_line(1)

		-- Exit insert mode (optional)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	end, { buffer = popup.bufnr, noremap = true })
	-- Close on <Esc>
	popup:map("n", "<Esc>", function()
		popup:unmount()
	end, { noremap = true })
end

return M
