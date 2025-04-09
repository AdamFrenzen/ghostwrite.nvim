local highlights = require("ghostwrite.diff.highlights")
local diff_keybinds = require("ghostwrite.diff.keybinds")

local Diff = {}
Diff.__index = Diff

function Diff:new(opts)
	local diff = setmetatable({
		id = opts.id,
		file = opts.file,
		start_line = opts.start_line,
		end_line = opts.end_line,
		current = opts.current,
		suggested = opts.suggested,
		--
		state = "pending",
		bufnr = opts.bufnr or vim.api.nvim_get_current_buf(),
		ns_id = opts.ns_id or vim.api.nvim_create_namespace("ghostwrite_diff_" .. opts.id),
	}, self)

	diff:render()
	diff:start_watching_line()

	return diff
end

function Diff:render()
	-- Highlights the original (current) lines of a diff directly in the buffer.
	-- Each line is broken into segments tagged as "same" or "diff" and styled accordingly.
	local function highlight_current_lines()
		-- Iterate over all lines affected by the diff (can be multi-line)
		for line_number = self.start_line, self.end_line do
			local line = self.current[line_number]
			local col = 0 -- Track the starting column for each segment

			-- Apply highlight to each segment in the line
			for _, segment in ipairs(line.segments) do
				local len = vim.fn.strdisplaywidth(segment.text)

				-- Highlight the segment from 'col' to 'col + len' using the tag's highlight group
				vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, line_number, col, {
					end_col = col + len,
					hl_group = highlights.current[segment.tag], -- red or bright red highlight
					hl_mode = "combine",
				})

				col = col + len -- Move the column pointer forward for the next segment
			end
		end
	end

	-- Renders virtual lines beneath the current diff lines to show the suggested replacement.
	-- Each suggested line is broken into segments tagged as "same" or "diff" and styled accordingly.
	local function render_suggested_lines()
		-- Iterate over all lines affected by the diff (can be multi-line)
		for line_number = self.start_line, self.end_line do
			local line = self.suggested[line_number]
			local virt_line = {}

			-- Build the virtual line as a series of { text, highlight } tuples
			for _, segment in ipairs(line.segments) do
				local hl = highlights.suggested[segment.tag]
				table.insert(virt_line, { segment.text, hl })
			end

			-- Render the virtual line below the corresponding buffer line
			vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, line_number, 0, {
				virt_lines = { virt_line },
				hl_mode = "combine",
			})
		end
	end

	highlight_current_lines()
	render_suggested_lines()
end

function Diff:clear()
	vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
	diff_keybinds.remove_line_listener(self.bufnr, self.ns_id)
end

return Diff
