local config = require("ghostwrite.config").get()
local utils = require("ghostwrite.utils")
local M = {}

function M.register()
	local bind_opts = config.default_bind_opts

	-- development command
	vim.keymap.set(
		"n",
		"<leader>Gr",
		"<cmd>ReloadGhostwrite<cr>",
		vim.tbl_extend("force", bind_opts, {
			desc = "Ghostwrite: Reload plugin",
		})
	)

	-- inline chat
	vim.keymap.set(
		"n",
		"<leader>Gi",
		"<cmd>GhostwriteInline<cr>",
		vim.tbl_extend("force", bind_opts, {
			desc = "Ghostwrite: Inline Chat",
		})
	)

	-- chat panel
	vim.keymap.set(
		"n",
		"<leader>Gc",
		"<cmd>GhostwriteChat<cr>",
		vim.tbl_extend("force", bind_opts, {
			desc = "Ghostwrite: Chat Panel",
		})
	)

	-- save visual command keys so we can alert if they overlap
	local visual_command_keys = {}
	local function add_command_key(key)
		for _, v in ipairs(visual_command_keys) do
			if v == key then
				error(
					"ghostwrite: visual mode command key overlap at <leader>G"
						.. key
						.. ". Remove or change duplicate in config."
				)
			end
		end

		table.insert(visual_command_keys, key)
	end

	-- open chat panel with visual selection as context
	add_command_key("c")
	vim.keymap.set(
		"v",
		"<leader>Gc",
		function()
			local selection = utils.get_visual_metadata()
			-- TODO: set up chat context
			-- require("ghostwrite.chat").open(selection)
		end,
		vim.tbl_extend("force", bind_opts, {
			desc = "Open In Chat Panel",
		})
	)

	-- open inline chat with visual selection as context
	add_command_key("i")
	vim.keymap.set(
		"v",
		"<leader>Gi",
		function()
			local selection_context = utils.get_visual_metadata()
			require("ghostwrite.inline").get_user_input(selection_context)
		end,
		vim.tbl_extend("force", bind_opts, {
			desc = "Open In Inline Chat",
		})
	)

	for key, action in pairs(config.prompt_templates) do
		-- open inline chat with visual selection and bypass user input with a preset prompt
		add_command_key(key)
		vim.keymap.set(
			"v",
			"<leader>G" .. key,
			function()
				local selection = utils.get_visual_metadata()

				local prompt = utils.interpolate_template(action.prompt, {
					language = selection.language,
					filename = selection.filename,
				})

				require("ghostwrite.inline").send_user_input(prompt, selection)
			end,
			vim.tbl_extend("force", bind_opts, {
				desc = "" .. action.desc,
			})
		)
	end
end

return M
