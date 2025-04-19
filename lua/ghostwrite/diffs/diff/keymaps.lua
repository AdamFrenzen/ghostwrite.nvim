local config = require("ghostwrite.config").get()
local actions = require("ghostwrite.diffs.diff.actions")

local M = {}

function M.set_keymap(id)
	-- Set line-local keymaps for diff interaction.
	-- These use user-configured keys and may override default Vim behavior.
	vim.keymap.set("n", config.diff_keybinds.accept_key, function()
		actions.accept(id)
	end, {
		buffer = 0,
		desc = "Accept diff (default: Y, overrides 'yank to end of line')",
	})
	vim.keymap.set("n", config.diff_keybinds.reject_key, function()
		actions.reject(id)
	end, {
		buffer = 0,
		desc = "Reject diff (default: N, overrides 'previous search result')",
	})
end

function M.remove_keymap()
	local function is_key_mapped(mode, lhs)
		for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
			if map.lhs == lhs then
				return true
			end
		end
		return false
	end

	if is_key_mapped("n", config.diff_keybinds.accept_key) then
		vim.keymap.del("n", config.diff_keybinds.accept_key, { buffer = 0 })
	end

	if is_key_mapped("n", config.diff_keybinds.reject_key) then
		vim.keymap.del("n", config.diff_keybinds.reject_key, { buffer = 0 })
	end
end

return M
