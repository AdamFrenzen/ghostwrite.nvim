local M = {}

--- Interpolate %{var} placeholders in a template string
-- @param template string The string with %{placeholders}
-- @param vars table A table of key-value pairs to fill in
-- @return string
function M.interpolate_template(template, vars)
	return (template:gsub("%%{(.-)}", function(key)
		return vars[key] or ""
	end))
end

--- Extract metadata about the current visual selection to send as context to the backend.
-- @return table containing file path, file name, language, range (start/end positions), and optionally buffer content
function M.get_visual_metadata()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local file = vim.fn.expand("%:p")
	local filename = vim.fn.fnamemodify(file, ":t")
	local language = vim.filetype.match({ filename = file }) or vim.bo.filetype

	local context = {
		file = file,
		filename = filename,
		language = language,
		range = {
			start = { line = start_pos[2], col = start_pos[3] },
			["end"] = { line = end_pos[2], col = end_pos[3] },
		},
	}

	-- If buffer has unsaved changes, include full buffer content
	if vim.bo.modified then
		context.buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	end

	return context
end

--- Extract context from the current cursor position for inline prompts.
-- @return table containing file path, file name, language, range, and optionally buffer content
function M.get_inline_context()
	local file = vim.fn.expand("%:p")
	local filename = vim.fn.fnamemodify(file, ":t")
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local language = vim.filetype.match({ filename = file }) or vim.bo.filetype

	local context = {
		file = file,
		filename = filename,
		language = language,
		range = {
			start = { line = line, col = 1 },
			["end"] = { line = line, col = -1 }, -- Single line
		},
	}

	if vim.bo.modified then
		context.buffer = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	end

	return context
end

return M
