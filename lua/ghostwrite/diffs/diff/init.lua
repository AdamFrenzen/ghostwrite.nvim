local highlights = require("ghostwrite.diffs.diff.highlights")

local Diff = {}
Diff.__index = Diff

function Diff:new(opts)
	local diff = setmetatable({
		id = opts.id,
		file = opts.file,
		start_line = opts.start_line,
		end_line = opts.end_line,
		new_lines = opts.new_lines,
		--
		bufnr = vim.api.nvim_get_current_buf(),
		ns_id = vim.api.nvim_create_namespace("ghostwrite_diff_" .. opts.id),
		diff_tooltip_id = nil,
	}, self)

	diff:render()
	return diff
end

function Diff:render()
	-- Highlights the original (current) lines of a diff directly in the buffer.
	-- Each line is broken into segments tagged as "same" or "diff" and styled accordingly.
	local function highlight_current_lines()
		-- Iterate over all lines affected by the diff (can be multi-line)
		for line_number = self.start_line, self.end_line do
			local line = self.new_lines[line_number]
			local col = 0 -- Track the starting column for each segment

			-- TODO: make a line -> segments fn

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
		local virt_lines = {}
		-- Iterate over all lines affected by the diff (can be multi-line)
		for line_number = self.start_line, self.end_line do
			local line = self.suggested[line_number]
			local virt_line = {}

			-- Build the virtual line as a series of { text, highlight } tuples
			for _, segment in ipairs(line.segments) do
				local hl = highlights.suggested[segment.tag]
				table.insert(virt_line, { segment.text, hl })
			end

			table.insert(virt_lines, virt_line)
		end

		-- Render the virtual lines together after the current lines
		vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, self.end_line, 0, {
			virt_lines = virt_lines,
			hl_mode = "combine",
		})
	end

	highlight_current_lines()
	render_suggested_lines()
end

function Diff:render_tooltip()
	local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
	self.diff_tooltip_id = vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, current_line, 0, {
		virt_text = {
			{ " ", "Normal" }, -- padding space for more separation
			{ "[󰊠 -+] Y/N", "GhostwriteDiffHelper" },
		},
		virt_text_pos = "eol", -- aligns the virtual text at the end of the line
	})
end

function Diff:derender_tooltip()
	if self.diff_tooltip_id then
		vim.api.nvim_buf_del_extmark(self.bufnr, self.ns_id, self.diff_tooltip_id)
		self.diff_tooltip_id = nil
	end
end

function Diff:clear()
	self:derender_tooltip()
	vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)
end

return Diff
