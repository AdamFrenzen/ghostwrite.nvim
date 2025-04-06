local M = {}

local defaults = {
	default_bind_opts = { noremap = true, silent = true, nowait = true },
	prompt_templates = {
		e = { desc = "Explain This Code", prompt = "Explain this %{language} code from %{filename}:" },
		C = { desc = "Comment This Code", prompt = "Add comments to this %{language} code from %{filename}:" },
		f = {
			desc = "Fix This Code",
			prompt = "Determine what is wrong and fix this %{language} code from %{filename}:",
		},
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
