local config = require("ghostwrite.config")
local M = {}

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("ReloadGhostwrite", ReloadGhostwrite, {})
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").open, {})
	vim.api.nvim_create_user_command("GhostwriteChat", require("ghostwrite.chat").open, {})

	-- development command
	vim.keymap.set("n", "<leader>Gr", "<cmd>ReloadGhostwrite<cr>", {
		desc = "Ghostwrite: Reload plugin",
		noremap = true,
		silent = true,
	})
	-- inline chat
	vim.keymap.set("n", "<leader>Gi", "<cmd>GhostwriteInline<cr>", {
		desc = "Ghostwrite: Inline Chat",
		noremap = true,
		silent = true,
	})
	-- chat panel
	vim.keymap.set("n", "<leader>Gc", "<cmd>GhostwriteChat<cr>", {
		desc = "Ghostwrite: Reload plugin",
		noremap = true,
		silent = true,
	})
end

function _G.ReloadGhostwrite()
	require("plenary.reload").reload_module("ghostwrite")
	require("ghostwrite").setup()
	print("🔄 Ghostwrite reloaded!")
end

return M
