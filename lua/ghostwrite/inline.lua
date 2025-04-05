local config = require("ghostwrite.config").get()
local Popup = require("nui.popup")
local M = {}

function M.open()
	-- get the start of editor, accounts for line number section
	local function get_text_start_col()
		local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
		return (wininfo and wininfo[1] and wininfo[1].textoff) or 0
	end

	local cursor_line = vim.fn.winline()
	local col_offset = get_text_start_col()
	local row = math.max(0, cursor_line - 3)

	-- forward declare
	local get_dummy_ai_response

	local function popup(opts)
		return {
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
		}
	end

	local function user_input()
		local user_popup = Popup(popup({
			bottom = " [Enter] send [Esc] cancel ",
			row = row,
			col = col_offset,
			height = 1,
		}))
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
			local line = vim.api.nvim_buf_get_lines(user_popup.bufnr, 0, 1, false)[1] or ""
			user_popup:unmount()
			get_dummy_ai_response(line)
		end

		user_popup:map("n", "o", ignore_key, config.default_bind_opts)
		user_popup:map("n", "O", ignore_key, config.default_bind_opts)
		user_popup:map("n", "<Esc>", close, config.default_bind_opts)
		user_popup:map("i", "<CR>", send, config.default_bind_opts)
	end

	user_input()

	get_dummy_ai_response = function(line)
		local lines = {
			" " .. line,
			"󰊠 `print(data)` is displaying data",
		}
		local count = #lines

		local response_popup = Popup(popup({
			bottom = " [y] apply  [n] dismiss  [→] move to chat ",
			row = row - count + 1,
			col = col_offset,
			height = count,
		}))
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
end

return M
