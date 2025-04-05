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
		action_is_delete = false,
		action = function()
			print("close")
		end,
	}

	local context_button = {
		label = "[ context]",
		action_is_delete = false,
		action = function()
			print("context")
		end,
	}

	local context_items = {
		{
			label = "main.rs:10-20",
			action_is_delete = true,
			action = function()
				-- eventually remove the file from context here
				print("main.rs")
			end,
		},
		{
			label = "init.lua",
			action_is_delete = true,
			action = function()
				-- eventually remove the file from context here
				print("init.lua")
			end,
		},
	}

	M.all_buttons = {}
	-- add single buttons
	table.insert(M.all_buttons, template_button)
	table.insert(M.all_buttons, context_button)
	-- add buttons from conttext_items
	for _, button in ipairs(context_items) do
		table.insert(M.all_buttons, button)
	end

	local function build_line()
		local line_parts = {}
		local visual_len = 0

		-- add [templates] button
		table.insert(line_parts, " " .. template_button.label .. " ")
		template_button.start_col = #" " -- leading padding space
		visual_len = #table.concat(line_parts)
		template_button.end_col = visual_len - #" " -- minus the trailing space bytes

		-- add [context] button
		table.insert(line_parts, context_button.label .. ": ")
		context_button.start_col = visual_len
		visual_len = #table.concat(line_parts)
		context_button.end_col = visual_len - #": " -- again, accounting for ": " bytes

		-- add context buttons
		for i, btn in ipairs(context_items) do
			if i > 1 then
				table.insert(line_parts, ", ")
				visual_len = #table.concat(line_parts)
			end

			btn.start_col = visual_len
			table.insert(line_parts, btn.label)
			visual_len = #table.concat(line_parts)
			btn.end_col = visual_len
		end

		return table.concat(line_parts)
	end

	vim.bo[toolbar_popup.bufnr].modifiable = true

	-- add the toolbar text and change the text color to blend in
	local function draw_toolbar()
		vim.api.nvim_buf_set_lines(toolbar_popup.bufnr, 0, 1, false, { build_line() })
		-- highlight the toolbar
		vim.highlight.range(
			toolbar_popup.bufnr,
			vim.api.nvim_create_namespace("ghostwrite_toolbar_text"),
			"FloatBorder", -- make text same color as the nui borders
			{ 0, 0 }, -- start: line 0, col 0
			{ 0, -1 }, -- end: line 0, col -1 (to end of line)
			{ inclusive = true }
		)
	end
	draw_toolbar()

	M.draw_toolbar = draw_toolbar
	M.toolbar_popup = toolbar_popup
	return toolbar_popup
end

function M.on_focus(winid)
	-- move cursor onto button
	local function set_cursor(index)
		if winid then
			vim.api.nvim_win_set_cursor(winid, { 1, M.all_buttons[index].start_col })
		end
	end

	-- highlight selected button
	vim.api.nvim_set_hl(0, "GhostwriteRedBackground", { bg = "#8b2c2c" })
	local ns_id = vim.api.nvim_create_namespace("ghostwrite_toolbar_text_select")
	local selected_button_index = 1
	local function highlight_button(index)
		local button = M.all_buttons[index]
		vim.highlight.range(
			M.toolbar_popup.bufnr,
			ns_id,
			button.action_is_delete and "GhostwriteRedBackground" or "Visual",
			{ 0, button.start_col },
			{ 0, button.end_col },
			{ inclusive = false }
		)
	end

	local function redraw_toolbar(index)
		M.draw_toolbar()
		set_cursor(index)
		highlight_button(index)
	end
	redraw_toolbar(selected_button_index)

	local function select_left()
		if selected_button_index > 1 then
			selected_button_index = selected_button_index - 1
		end
		redraw_toolbar(selected_button_index)
	end

	local function select_right()
		if selected_button_index < 4 then
			selected_button_index = selected_button_index + 1
		end
		redraw_toolbar(selected_button_index)
	end

	local function select()
		M.all_buttons[selected_button_index].action()
	end

	M.toolbar_popup:map("n", "<Left>", select_left, M.default_bind_opts)
	M.toolbar_popup:map("n", "h", select_left, M.default_bind_opts)
	M.toolbar_popup:map("n", "<Right>", select_right, M.default_bind_opts)
	M.toolbar_popup:map("n", "l", select_right, M.default_bind_opts)

	M.toolbar_popup:map("n", "<Cr>", select, M.default_bind_opts)
end

function M.on_unfocus()
	-- remove the button highlight when focus switches
	M.draw_toolbar()
end

return M
