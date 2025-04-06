local M = {}
local has_which_key, which_key = pcall(require, "which-key")

function M.register()
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

return M
