local M = {}

local defaults = {
	default_bind_opts = { noremap = true, silent = true, nowait = true },
	prompt_templates = {
		summarize = "Summarize the following code:",
		comment = "Add comments to this code:",
		fix = "Determine what is wrong and fix this code:",
	},
	model = "LLM-model-here",
}

local user_config = {}

function M.setup(opts)
	user_config = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.get()
	return user_config
end

return M
