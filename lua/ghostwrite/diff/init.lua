local M = {}
M.current_batch = {}

function M.set_batch(batch)
	M.current_batch = batch
end

function M.clear_batch()
	M.current_batch = {}
end

return M
