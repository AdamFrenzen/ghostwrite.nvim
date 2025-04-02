local M = {}

function M.setup()
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").open, {})
	vim.api.nvim_create_user_command("ReloadGhostwrite", ReloadGhostwrite, {})

	vim.keymap.set("n", "<leader>Gi", "<cmd>GhostwriteInline<cr>", {
		desc = "Ghostwrite: Inline Chat",
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
