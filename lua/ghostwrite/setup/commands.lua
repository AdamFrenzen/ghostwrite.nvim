local M = {}

-- Reload Ghostwrite plugin without restarting Neovim (for development)
function M.reload()
	local ok_reload = pcall(require("plenary.reload").reload_module, "ghostwrite")
	local ok_setup = pcall(require("ghostwrite").setup)
	if ok_reload and ok_setup then
		print("🔄 Ghostwrite reloaded!")
	else
		print("⚠️ Ghostwrite reload failed!")
	end
end

function M.register()
	-- Register :Ghostwrite commands
	vim.api.nvim_create_user_command("ReloadGhostwrite", M.reload, {
		desc = "Reload the Ghostwrite plugin",
	})
	vim.api.nvim_create_user_command("GhostwriteInline", require("ghostwrite.inline").get_user_input, {
		desc = "Open Ghostwrite inline chat",
	})
	vim.api.nvim_create_user_command("GhostwriteChat", require("ghostwrite.chat").open, {
		desc = "Open Ghostwrite side panel chat",
	})
end

return M
