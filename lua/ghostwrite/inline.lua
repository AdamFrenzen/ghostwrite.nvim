local Popup = require("nui.popup")
local Layout = require("nui.layout")
local M = {}

local function get_text_start_col()
	local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
	return (wininfo and wininfo[1] and wininfo[1].textoff) or 0
end

function M.open()
	local cursor_line = vim.fn.winline()
	local row = math.max(0, cursor_line - 3)
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

	local layout = Layout(
		{
			position = {
				row = row,
				col = col_offset,
			},
			size = {
				width = 80,
				height = 1,
			},
			relative = "win",
		},
		Layout.Box({
			Layout.Box(popup, { grow = 1 }),
		}, { dir = "col" })
	)

	layout:mount()

	vim.schedule(function()
		vim.cmd("startinsert")

		-- Disable accidental line breaks
		vim.keymap.set("n", "o", "<Nop>", { buffer = popup.bufnr, noremap = true })
		vim.keymap.set("n", "O", "<Nop>", { buffer = popup.bufnr, noremap = true })

		-- Close on Esc
		popup:map("n", "<Esc>", function()
			layout:unmount()
		end, { noremap = true })

		-- Handle <CR> to stream fake response
		vim.keymap.set("i", "<CR>", function()
			local line = vim.api.nvim_buf_get_lines(popup.bufnr, 0, 1, false)[1] or ""

			-- Replace input with user message
			vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, {
				"👤 " .. line,
				"",
			})

			local response_lines = {
				"🤖 Sure! Here's what I did:",
				" - Removed the unused import.",
				" - Wrapped the call in a try/catch.",
				" - Added fallback logic for null values.",
				" - Added fallback logic for null values.",
				" - Added fallback logic for null values.",
				" - Added fallback logic for null values.",
			}
			local function append_line(i)
				if i > #response_lines then
					return
				end

				local current_lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
				table.insert(current_lines, response_lines[i])
				vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, current_lines)

				local max_height = 20
				local content_height = #current_lines
				local border_padding = 2
				local total_height = math.min(content_height + border_padding, max_height)

				-- Resize both popup and layout to match
				popup:update_layout({
					size = {
						width = 80,
						height = total_height,
					},
				})

				layout:update({
					size = {
						width = 80,
						height = total_height,
					},
				})

				vim.defer_fn(function()
					append_line(i + 1)
				end, 100)
			end
			append_line(1)

			-- Optional: exit insert mode
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		end, { buffer = popup.bufnr, noremap = true })
	end)
end

return M
