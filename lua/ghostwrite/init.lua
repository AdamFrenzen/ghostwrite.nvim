local config = require("ghostwrite.config")
local M = {}

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("ReloadGhostwrite", ReloadGhostwrite, {})
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").open, {})
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
end

function _G.ReloadGhostwrite()
	require("plenary.reload").reload_module("ghostwrite")
	require("ghostwrite").setup()
	print("🔄 Ghostwrite reloaded!")
end

return M
