local M = {}

--- Setup Ghostwrite with user options.
-- @param opts table Configuration overrides
function M.setup(opts)
	require("ghostwrite.config").setup(opts)
	require("ghostwrite.setup.commands").register()
	require("ghostwrite.setup.keymaps").register()
	require("ghostwrite.setup.whichkey").register()
	require("ghostwrite.diffs.watcher").start()
end

return M
