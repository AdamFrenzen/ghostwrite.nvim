-- Set highlight groups for diff visualization

-- Green background for the suggested line
vim.api.nvim_set_hl(0, "GhostwriteDiffGreen", {
	fg = "#dbdbdb", -- light gray
	bg = "#123a1b", -- green
})
-- Bright green background for emphasizing specific differences in the suggestion
vim.api.nvim_set_hl(0, "GhostwriteDiffGreenBright", {
	fg = "#dbdbdb", -- light gray
	bg = "#156e2a", -- bright green
})

-- Red background for the original (current) line
vim.api.nvim_set_hl(0, "GhostwriteDiffRed", {
	-- Optional fg: remove to preserve original syntax highlighting
	fg = "#dbdbdb", -- light gray
	bg = "#450c0f", -- red
})
-- Bright red background for emphasizing specific differences in the original
vim.api.nvim_set_hl(0, "GhostwriteDiffRedBright", {
	-- Optional fg: remove to preserve original syntax highlighting
	fg = "#dbdbdb", -- light gray
	bg = "#6b1015", -- bright red
})

-- Purple background and gray text for the helper virtual line
vim.api.nvim_set_hl(0, "GhostwriteDiffHelper", {
	bg = "#3b245a", -- dark royal purple
	fg = "#707070", -- dark gray
})

return {
	current = {
		same = "GhostwriteDiffRed",
		diff = "GhostwriteDiffRedBright",
	},
	suggested = {
		same = "GhostwriteDiffGreen",
		diff = "GhostwriteDiffGreenBright",
	},
}
