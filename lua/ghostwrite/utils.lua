local M = {}

--- Extract metadata about the current visual selection to send as context to the backend.
-- @return table containing file path, start/end positions, and selection mode
function M.get_visual_metadata()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local mode = vim.fn.visualmode() -- char, line, or block
	local filepath = vim.fn.expand("%:p")

	return {
		file = filepath,
		start = { line = start_pos[2], col = start_pos[3] },
		["end"] = { line = end_pos[2], col = end_pos[3] },
		mode = mode,
	}
end

return M
