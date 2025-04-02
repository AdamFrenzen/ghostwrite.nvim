local M = {}
M.default_bind_opts = { noremap = true, silent = true, nowait = true }

function M.setup()
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").open, {})
	vim.api.nvim_create_user_command("GhostwriteChat", require("ghostwrite.chat").open, {})
	vim.api.nvim_create_user_command("ReloadGhostwrite", ReloadGhostwrite, {})

	vim.keymap.set("n", "<leader>Gi", "<cmd>GhostwriteInline<cr>", {
		desc = "Ghostwrite: Inline Chat",
		noremap = true,
		silent = true,
	})
	vim.keymap.set("n", "<leader>Gc", "<cmd>GhostwriteChat<cr>", {
		desc = "Ghostwrite: Reload plugin",
		noremap = true,
		silent = true,
	})
	vim.keymap.set("n", "<leader>Gr", "<cmd>ReloadGhostwrite<cr>", {
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
