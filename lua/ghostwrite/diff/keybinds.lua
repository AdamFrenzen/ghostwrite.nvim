local config = require("ghostwrite.config").get()
local M = {}

function M.set_keybind()
	local function accept()
		print("ACCEPTED")
	end

	local function reject()
		print("REJECTED")
	end

	-- Set buffer-local keymaps for diff interaction.
	-- These use user-configured keys and may override default Vim behavior.
	vim.keymap.set("n", config.diff_keybinds.accept_key, accept, {
		buffer = 0,
		desc = "Accept diff (default: Y, overrides 'yank to end of line')",
	})
	vim.keymap.set("n", config.diff_keybinds.reject_key, reject, {
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

	local accept_map = is_key_mapped("n", config.diff_keybinds.accept_key)
	if accept_map then
		vim.keymap.del("n", config.diff_keybinds.accept_key, { buffer = 0 })
	end

	local reject_map = is_key_mapped("n", config.diff_keybinds.reject_key)
	if reject_map then
		vim.keymap.del("n", config.diff_keybinds.reject_key, { buffer = 0 })
	end
end

function M.attach_line_listener(target_line_number, bufnr, ns_id)
	-- Create or reuse a unique autocmd group
	local group = vim.api.nvim_create_augroup("GhostwriteDiffWatcher", { clear = true })
	local is_keybind_active = false

	local function entered_line()
		-- Render a helper to show how to accept/reject
		M.diff_tag = vim.api.nvim_buf_set_extmark(bufnr, ns_id, target_line_number, 0, {
			virt_text = {
				{ " ", "Normal" },
				{ "[󰊠 -+] Y/N", "GhostwriteDiffHelper" },
			},
			virt_text_pos = "eol", -- aligns the virtual text at the end of the line
		})

		M.set_keybind()
		is_keybind_active = true
	end

	local function exited_line()
		if M.diff_tag then
			vim.api.nvim_buf_del_extmark(bufnr, ns_id, M.diff_tag)
			M.diff_tag = nil
		end

		M.remove_keybind()
		is_keybind_active = false
	end

	local function listener()
		-- `nvim_win_get_cursor()` is 1-based; we subtract 1 to make it 0-based to match `target_line_number`
		local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1

		if current_line == target_line_number and not is_keybind_active then
			entered_line()
		elseif current_line ~= target_line_number and is_keybind_active then
			exited_line()
		end
	end

	-- See if user is already at the target line
	if (vim.api.nvim_win_get_cursor(0)[1] - 1) == target_line_number and not is_keybind_active then
		entered_line()
	end

	-- Watch for cursor movement in normal mode
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group,
		callback = listener,
	})

	-- Insert mode turn off the accept/reject keybinds
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = M.remove_keybind,
	})

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = M.set_keybind,
	})
end

function M.remove_line_listener()
	M.remove_keybind()
	vim.api.nvim_clear_autocmds({ group = M.autocm_group })
end

return M
