local config = require("ghostwrite.config").get()
local actions = require("ghostwrite.diff.actions")

local M = {}
M.is_keybind_active = false
M.autocmd_group = "GhostwriteDiffWatcher"
M.diff_helper_id = nil

function M.set_keybind()
	-- Set line-local keymaps for diff interaction.
	-- These use user-configured keys and may override default Vim behavior.
	vim.keymap.set("n", config.diff_keybinds.accept_key, actions.accept, {
		buffer = 0,
		desc = "Accept diff (default: Y, overrides 'yank to end of line')",
	})
	vim.keymap.set("n", config.diff_keybinds.reject_key, actions.reject, {
		buffer = 0,
		desc = "Reject diff (default: N, overrides 'previous search result')",
	})
end

function M.remove_keybind()
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

function M.entered_line(bufnr, ns_id, target_line_number)
	-- Render a helper to show how to accept/reject
	M.diff_helper_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, target_line_number, 0, {
		virt_text = {
			{ " ", "Normal" }, -- padding space for more separation
			{ "[󰊠 -+] Y/N", "GhostwriteDiffHelper" },
		},
		virt_text_pos = "eol", -- aligns the virtual text at the end of the line
	})

	M.set_keybind()
	M.is_keybind_active = true
end

function M.exited_line(bufnr, ns_id)
	if M.diff_helper_id then
		vim.api.nvim_buf_del_extmark(bufnr, ns_id, M.diff_helper_id)
		M.diff_helper_id = nil
	end

	M.remove_keybind()
	M.is_keybind_active = false
end

function M.check_and_handle_line_focus(target_line_number, bufnr, ns_id)
	local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1

	if current_line == target_line_number and not M.is_keybind_active then
		M.entered_line(bufnr, ns_id, target_line_number)
	elseif current_line ~= target_line_number and M.is_keybind_active then
		M.exited_line(bufnr, ns_id)
	end
end

function M.attach_line_listener(target_line_number, bufnr, ns_id)
	-- Create or reuse a unique autocmd group
	local group = vim.api.nvim_create_augroup(M.autocmd_group, { clear = true }) -- clear so we can easily remove

	-- Do initial check to see if diff was generated on the line that the curosor is already in
	M.check_and_handle_line_focus(target_line_number, bufnr, ns_id)

	-- Watch for cursor movement in normal mode
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group,
		callback = function()
			M.check_and_handle_line_focus(target_line_number, bufnr, ns_id)
		end,
	})

	-- Remove the keymaps when in insert mode
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			M.exited_line(bufnr, ns_id)
		end,
	})

	-- Check if cursor is in the line when you leave insert mode
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			M.check_and_handle_line_focus(target_line_number, bufnr, ns_id)
		end,
	})
end

function M.remove_line_listener(bufnr, ns_id)
	M.exited_line(bufnr, ns_id)
	vim.api.nvim_clear_autocmds({ group = M.autocmd_group })
end

return M
