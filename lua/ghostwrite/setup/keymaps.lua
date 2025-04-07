local config = require("ghostwrite.config").get()
local utils = require("ghostwrite.utils")
local M = {}

function M.register()
	local keybind_opts = config.default_keybind_opts

	-- Reload Ghostwrite plugin without restarting Neovim (for development)
	vim.keymap.set(
		"n",
		"<leader>Gr",
		"<cmd>ReloadGhostwrite<cr>",
		vim.tbl_extend("force", keybind_opts, {
			desc = "Reload Plugin", -- which-key command label
		})
	)

	-- Open the inline chat popup
	vim.keymap.set(
		"n",
		"<leader>Gi",
		"<cmd>GhostwriteInline<cr>",
		vim.tbl_extend("force", keybind_opts, {
			desc = "Inline Chat",
		})
	)

	-- Open the chat panel
	vim.keymap.set(
		"n",
		"<leader>Gc",
		"<cmd>GhostwriteChat<cr>",
		vim.tbl_extend("force", keybind_opts, {
			desc = "Chat Panel",
		})
	)

	-- Store visual command keys so we can alert if they overlap
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

	-- Open chat panel with visual selection as context
	add_command_key("c")
	vim.keymap.set(
		"v",
		"<leader>Gc",
		function()
			local selection = utils.get_visual_metadata()
			-- TODO: set up chat context
			-- require("ghostwrite.chat").open(selection)
		end,
		vim.tbl_extend("force", keybind_opts, {
			desc = "Open In Chat Panel",
		})
	)

	-- Open inline chat with visual selection as context
	add_command_key("i")
	vim.keymap.set(
		"v",
		"<leader>Gi",
		function()
			local selection_context = utils.get_visual_metadata()
			require("ghostwrite.inline").get_user_input(selection_context)
		end,
		vim.tbl_extend("force", keybind_opts, {
			desc = "Open In Inline Chat",
		})
	)

	-- Set keymaps for visual-mode LLM actions (user-defined + defaults like "summarize", "fix", "comment")
	for key, action in pairs(config.actions) do
		-- Send a predefined prompt to inline chat using the visual selection as context
		add_command_key(key)
		vim.keymap.set(
			"v",
			"<leader>G" .. key,
			function()
				local selection = utils.get_visual_metadata()

				-- Replace %{var} placeholders in the action prompt with file info (for better LLM context)
				local prompt = utils.interpolate_template(action.prompt, {
					language = selection.language,
					filename = selection.filename,
				})

				require("ghostwrite.inline").send_user_input(prompt, selection)
			end,
			vim.tbl_extend("force", keybind_opts, {
				desc = action.desc, -- Config defined action commmand label for which-key
			})
		)
	end
end

return M
