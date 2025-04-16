local keymaps = require("ghostwrite.diff.keymaps")

local M = {}
M.diffs = {}
M.active_diff = nil
M.diff_tooltip_id = nil
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

function M.activate_diff(diff)
	local function render_tooltip()
		local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
		M.diff_tooltip_id = vim.api.nvim_buf_set_extmark(M.active_diff.bufnr, M.active_diff.ns_id, current_line, 0, {
			virt_text = {
				{ " ", "Normal" }, -- padding space for more separation
				{ "[󰊠 -+] Y/N", "GhostwriteDiffHelper" },
			},
			virt_text_pos = "eol", -- aligns the virtual text at the end of the line
		})
	end

	M.active_diff = diff
	render_tooltip()
	keymaps.set_keymap(diff.id)
end

function M.deactivate_diff()
	local function derender_tooltip()
		if M.diff_tooltip_id then
			vim.api.nvim_buf_del_extmark(M.active_diff.bufnr, M.active_diff.ns_id, M.diff_tooltip_id)
			M.diff_tooltip_id = nil
		end
	end

	derender_tooltip()
	keymaps.remove_keymap()
	M.active_diff = nil
end

function M.start()
	-- Create or reuse a unique autocmd group
	local group = vim.api.nvim_create_augroup(M.autocmd_group, { clear = true }) -- clear so we can easily remove

	-- Watch for cursor movement in normal mode
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group,
		callback = function()
			M.deactivate_diff()
			local diff = M.get_diff_under_cursor()
			if diff then
				M.activate_diff(diff)
			end
		end,
	})

	-- Remove the keymaps when in insert mode
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function()
			M.deactivate_diff()
		end,
	})

	-- Check if cursor is in the line when you leave insert mode
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = group,
		callback = function()
			M.deactivate_diff()
			local diff = M.get_diff_under_cursor()
			if diff then
				M.activate_diff(diff)
			end
		end,
	})
end

function M.update()
	M.diffs = require("ghostwrite.diff.manager").get_all()
end

function M.stop()
	vim.api.nvim_clear_autocmds({ group = M.autocmd_group })
end

return M
