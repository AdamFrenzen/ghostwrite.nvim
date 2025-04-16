local M = {}

function M.accept(id)
	print("ACCEPTED", id)
end

function M.reject(id)
	print("REJECTED", id)
end

return M
