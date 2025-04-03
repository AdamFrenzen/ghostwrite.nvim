local Layout = require("nui.layout")
local ChatOutput = require("ghostwrite.chat_output")
local ChatInput = require("ghostwrite.chat_input")
local M = {}

local chat_panel = {}
chat_panel.width = 60
chat_panel.height = vim.o.lines - 3
chat_panel.output_height = math.floor(chat_panel.height * 0.8)
chat_panel.input_height = chat_panel.height - chat_panel.output_height

local ghostwrite_output_popup
local ghostwrite_input_popup
local ghostwrite_chat_panel

function M.open()
	if not ghostwrite_chat_panel then
		local output_popup = ChatOutput.create(chat_panel)
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
				Layout.Box(input_popup, { size = chat_panel.input_height }),
			}, { dir = "col" })
		)

		layout:mount()
		ghostwrite_chat_panel = layout

		ghostwrite_output_popup = output_popup
		ghostwrite_input_popup = input_popup
		ghostwrite_chat_panel = layout
	else -- chat panel has been previously created, we want to reopen
		ghostwrite_chat_panel:show()
	end

	local input_popup = ghostwrite_input_popup
	local output_popup = ghostwrite_output_popup
	local layout = ghostwrite_chat_panel

	-- start with the input pane focused
	local current_focus = 2

	-- toggle between output and input
	local function toggle_focus()
		if current_focus == 1 then
			vim.api.nvim_set_current_win(input_popup.winid)
			current_focus = 2
		else
			vim.bo[output_popup.bufnr].modifiable = true
			vim.api.nvim_set_current_win(output_popup.winid)
			vim.bo[output_popup.bufnr].modifiable = false
			current_focus = 1
		end
	end

	local function close()
		layout:hide()
	end

	-- set toggle keys for both popups
	for _, popup in ipairs({ output_popup, input_popup }) do
		popup:map("n", "<Up>", toggle_focus, M.default_bind_opts)
		popup:map("n", "<Down>", toggle_focus, M.default_bind_opts)
		popup:map("n", "<Tab>", toggle_focus, M.default_bind_opts)
	end

	output_popup:map("n", "<Esc>", close, M.default_bind_opts)
	input_popup:map("n", "<Esc>", close, M.default_bind_opts)
end

return M
