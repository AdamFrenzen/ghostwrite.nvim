local config = require("ghostwrite.config")
local utils = require("ghostwrite.utils")
local has_which_key, which_key = pcall(require, "which-key")
local M = {}

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("ReloadGhostwrite", ReloadGhostwrite, {})
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").get_user_input, {})
	vim.api.nvim_create_user_command("GhostwriteChat", require("ghostwrite.chat").open, {})

	local bind_opts = config.get().default_bind_opts

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
			-- inline.lua call for attaching context to inline chat
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
			local selection = utils.get_visual_metadata()
			-- inline.lua call for attaching context to inline chat
		end,
		vim.tbl_extend("force", bind_opts, {
			desc = "Open In Inline Chat",
		})
	)

	for key, action in pairs(config.get().prompt_templates) do
		-- open inline chat with visual selection and bypass user input with a preset prompt
		add_command_key(key)
		vim.keymap.set(
			"v",
			"<leader>G" .. key,
			function()
				local selection = utils.get_visual_metadata()
				-- inline.lua call for attaching context to inline chat
				-- inline.lua call for sending user input
			end,
			vim.tbl_extend("force", bind_opts, {
				desc = "" .. action.desc,
			})
		)
	end

	-- add commands to which-key
	if has_which_key then
		which_key.add({
			{ "<leader>G", group = "Ghostwrite", icon = { icon = "󰊠", color = "purple" }, mode = "n" },
			{ "<leader>G", group = "Ghostwrite", icon = { icon = "󰊠", color = "purple" }, mode = "v" },

			{ "<leader>Gi", cmd = "<cmd>GhostwriteInline<cr>", desc = "Inline Chat" },
			{ "<leader>Gc", cmd = "<cmd>GhostwriteChat<cr>", desc = "Chat Panel" },
			{ "<leader>Gr", cmd = "<cmd>ReloadGhostwrite<cr>", desc = "Reload Plugin" },
		})
	end
end

function _G.ReloadGhostwrite()
	require("plenary.reload").reload_module("ghostwrite")
	require("ghostwrite").setup()
	print("🔄 Ghostwrite reloaded!")
end

return M
