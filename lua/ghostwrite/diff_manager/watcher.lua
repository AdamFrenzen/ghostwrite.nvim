local keymaps = require("ghostwrite.diff.keymaps")

local M = {}
M.diffs = {}
M.active_diff = nil
M.autocmd_group = "GhostwriteDiffWatcher"

function M.get_diff_under_cursor()
	-- Line of the cursor
	local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- make 0-based

	-- Loop through every diff
	for _, diff in pairs(M.diffs) do
		-- If current line is within the diff's range
		if current_line >= diff.start_line and current_line <= diff.end_line then
			return diff
		end
	end

	-- Cursor is not on a diff line
	return nil
end

function M.focus_diff(diff)
	M.active_diff = diff
	M.active_diff.render_tooltip()
	keymaps.set_keymap(diff.id)
end

function M.unfocus_diff()
	M.active_diff.derender_tooltip()
	keymaps.remove_keymap()
	M.active_diff = nil
end

function M.set_diff_focus()
	M.unfocus_diff()
	local diff = M.get_diff_under_cursor()
	if diff then
		M.focus_diff(diff)
	end
end

-- TODO: make a buffer_watcher and move the current buffer based watcher their, this file becomes a
function M.start()
	--[[
	-- Create or reuse a unique autocmd group
	local group = vim.api.nvim_create_augroup(M.autocmd_group, { clear = true }) -- clear so we can easily remove

	-- Check if cursor is indside a diff whenever the cursor moves
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group,
		callback = M.set_diff_focus,
	})

	-- Remove the keymaps when in insert mode
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = M.unfocus_diff,
	})

	-- Check if cursor is in the line when you leave insert mode
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = M.set_diff_focus,
	})
  --]]
	-- Watch for
end

function M.update()
	-- local file =
	-- M.diffs = require("ghostwrite.diff").get_diffs_from_file(file)
end

function M.stop()
	vim.api.nvim_clear_autocmds({ group = M.autocmd_group })
end

return M
