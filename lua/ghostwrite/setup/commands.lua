local M = {}

function M.reload()
	require("plenary.reload").reload_module("ghostwrite")
	require("ghostwrite").setup()
	print("🔄 Ghostwrite reloaded!")
end

function M.register()
	vim.api.nvim_create_user_command("ReloadGhostwrite", M.reload, {})
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").get_user_input, {})
	vim.api.nvim_create_user_command("GhostwriteChat", require("ghostwrite.chat").open, {})
end

return M
