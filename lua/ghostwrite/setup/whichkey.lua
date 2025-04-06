local M = {}
local has_which_key, which_key = pcall(require, "which-key")

function M.register()
	-- Add commands to which-key
	if has_which_key then
		which_key.add({
			-- Normal mode group
			{ "<leader>G", group = "Ghostwrite", icon = { icon = "󰊠", color = "purple" }, mode = "n" },
			-- Visual mode group
			{ "<leader>G", group = "Ghostwrite", icon = { icon = "󰊠", color = "purple" }, mode = "v" },
		})
	end
end

return M
