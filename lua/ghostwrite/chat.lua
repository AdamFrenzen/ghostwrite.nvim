local Layout = require("nui.layout")
local ChatOutput = require("ghostwrite.chat_output")
local ChatToolbar = require("ghostwrite.chat_toolbar")
local ChatInput = require("ghostwrite.chat_input")
local M = {}

local chat_panel = {}
chat_panel.width = 60
chat_panel.height = vim.o.lines - 3
chat_panel.output_height = math.floor(chat_panel.height * 0.8)
chat_panel.toolbar_height = 1
chat_panel.input_height = chat_panel.height - chat_panel.output_height - chat_panel.toolbar_height

local ghostwrite_output_popup
local ghostwrite_toolbar_popup
local ghostwrite_input_popup
local ghostwrite_chat_panel

function M.open()
	if not ghostwrite_chat_panel then
		local output_popup = ChatOutput.create(chat_panel)
		local toolbar_popup = ChatToolbar.create(chat_panel)
		local input_popup = ChatInput.create(chat_panel)

		local layout = Layout(
			{
				relative = "editor",
				position = {
					row = 1,
					col = vim.o.columns - chat_panel.width, -- right side of the screen
				},
				size = {
					width = chat_panel.width,
					height = chat_panel.height,
				},
			},
			Layout.Box({
				Layout.Box(output_popup, { size = chat_panel.output_height }),
				Layout.Box(toolbar_popup, { size = chat_panel.toolbar_height }),
				Layout.Box(input_popup, { size = chat_panel.input_height }),
			}, { dir = "col" })
		)

		layout:mount()
		ghostwrite_chat_panel = layout

		ghostwrite_output_popup = output_popup
		ghostwrite_toolbar_popup = toolbar_popup
		ghostwrite_input_popup = input_popup
		ghostwrite_chat_panel = layout
	else -- chat panel has been previously created, we want to reopen
		ghostwrite_chat_panel:show()
	end

	local input_popup = ghostwrite_input_popup
	local toolbar_popup = ghostwrite_toolbar_popup
	local output_popup = ghostwrite_output_popup
	local layout = ghostwrite_chat_panel

	local panes = {
		{ popup = output_popup },
		{
			popup = toolbar_popup,
			on_focus = function(winid)
				ChatToolbar.on_focus(winid)
			end,
			on_unfocus = ChatToolbar.on_unfocus,
		},
		{ popup = input_popup },
	}
	-- start with the input pane focused
	local current_focus = 3

	local function safely_focus_win(winid, bufnr)
		if not vim.bo[bufnr].modifiable then
			vim.bo[bufnr].modifiable = true
			vim.api.nvim_set_current_win(winid)
			vim.bo[bufnr].modifiable = false
		else
			vim.api.nvim_set_current_win(winid)
		end
	end

	local function set_focus(target_focus)
		local pane = panes[target_focus]

		-- unfocus previous pane
		if panes[current_focus].on_unfocus then
			panes[current_focus].on_unfocus()
		end

		-- set win to the popup
		safely_focus_win(pane.popup.winid, pane.popup.bufnr)

		-- trigger focus method
		if pane.on_focus then
			pane.on_focus(pane.popup.winid)
		end

		-- update focus
		current_focus = target_focus
	end
	-- init focus
	set_focus(current_focus)

	local function focus_up()
		local new_focus = nil
		if current_focus == 1 then
			new_focus = 3
		else
			new_focus = current_focus - 1
		end

		set_focus(new_focus)
	end

	local function focus_down()
		local new_focus = nil
		if current_focus == 3 then
			new_focus = 1
		else
			new_focus = current_focus + 1
		end

		set_focus(new_focus)
	end

	local function close()
		layout:hide()
	end

	-- set shared keys for all popups
	for _, popup in ipairs(panes) do
		-- pane movement
		popup.popup:map("n", "<Up>", focus_up, M.default_bind_opts)
		popup.popup:map("n", "<Down>", focus_down, M.default_bind_opts)
		popup.popup:map("n", "<Tab>", focus_up, M.default_bind_opts)
		-- exit
		popup.popup:map("n", "<Esc>", close, M.default_bind_opts)
	end
end

return M
