local Popup = require("nui.popup")
local M = {}

function M.create(chat_panel)
	local toolbar_popup = Popup({
		size = {
			width = chat_panel.width,
			height = chat_panel.output_height,
		},
		enter = false,
		focusable = true,
		buf_options = { bufhidden = "hide" },
		win_options = {
			winblend = 10,
		},
	})

	local template_button = {
		label = "[ templates]",
		action = function()
			print("close")
		end,
	}

	local context_button = {
		label = "[ context]",
		action = function()
			print("context")
		end,
	}

	local context_buttons = {
		{
			label = "main.rs:10-20", -- 13 len
			action = function()
				print("main.rs")
			end,
		},
		{
			label = "init.lua", -- 8 len
			action = function()
				print("init.lua")
			end,
		},
	}

	local function build_line()
		local line_parts = {}
		local visual_len = 0

		-- add [templates] button
		table.insert(line_parts, " " .. template_button.label .. " ")
		template_button.start_col = 1 -- leading padding space
		visual_len = vim.fn.strdisplaywidth(table.concat(line_parts))
		template_button.end_col = visual_len - 1 -- minus the trailing space

		-- add [context] button
		table.insert(line_parts, context_button.label .. ": ")
		context_button.start_col = visual_len
		visual_len = vim.fn.strdisplaywidth(table.concat(line_parts))
		context_button.end_col = visual_len - 2 -- again, accounting for ": "

		-- add context buttons
		for i, btn in ipairs(context_buttons) do
			if i > 1 then
				table.insert(line_parts, ", ")
				visual_len = visual_len + vim.fn.strdisplaywidth(", ")
			end

			btn.start_col = visual_len
			table.insert(line_parts, btn.label)
			visual_len = vim.fn.strdisplaywidth(table.concat(line_parts))
			btn.end_col = visual_len
		end

		return table.concat(line_parts)
	end

	vim.bo[toolbar_popup.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(toolbar_popup.bufnr, 0, 1, false, { build_line() })
	vim.highlight.range(
		toolbar_popup.bufnr,
		vim.api.nvim_create_namespace("toolbar_popup_style"),
		"FloatBorder", -- make text same color as the nui borders
		{ 0, 0 }, -- start: line 0, col 0
		{ 0, -1 }, -- end: line 0, col -1 (to end of line)
		{ inclusive = true }
	)
	vim.bo[toolbar_popup.bufnr].modifiable = false

	return toolbar_popup
end

return M
