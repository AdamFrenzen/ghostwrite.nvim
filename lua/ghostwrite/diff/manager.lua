local watcher = require("ghostwrite.diff.watcher")

local M = {}

M.diffs = {}

function M.add(diff)
	M.diffs[diff.id] = diff
	watcher.update()
	return diff.id
end

function M.remove(id)
	local diff = M.diffs[id]
	if diff then
		diff:clear()
		M.diffs[id] = nil
		watcher.update()
	end
end

function M.clear_all()
	for _, diff in pairs(M.diffs) do
		diff:clear()
	end
	M.diffs = {}
	watcher.update()
end

function M.get(id)
	return M.diffs[id]
end

function M.get_all()
	return M.diffs
end

return M
