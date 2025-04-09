local DiffManager = {}
DiffManager.__index = DiffManager

function DiffManager:new()
	return setmetatable({
		diffs = {}, -- key = id, value = Diff instance
	}, self)
end

function DiffManager:add(diff)
	self.diffs[diff.id] = diff
	return diff.id
end

function DiffManager:clear_all()
	for _, diff in pairs(self.diffs) do
		diff:clear()
	end
	self.diffs = {}
end

function DiffManager:remove(id)
	local diff = self.diffs[id]
	if diff then
		diff:clear()
		self.diffs[id] = nil
	end
end

function DiffManager:get(id)
	return self.diffs[id]
end

return DiffManager
