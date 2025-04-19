local Diff = require("ghostwrite.diff.diff")

local M = {}

-- Table for Diff instances - multiple files and multiple diffs per file
M.current_batch = {}

function M.set_batch(batch)
	M.current_batch = {}

	-- Restructure the `batch` payload into a table of Diff class instances
	for filename, file_data in pairs(batch.files) do
		-- Get all diffs in the file
		local diff_instances = {}
		for _, diff_payload in ipairs(file_data.diffs) do
			local diff_instance = Diff:new(diff_payload)
			table.insert(diff_instances, diff_instance)
		end

		-- Store the Diff class instances by filename
		M.current_batch[filename] = {
			diffs = diff_instances,
		}
	end
end

function M.get_diffs()
	local all_diffs = {}
	for _, file in pairs(M.current_batch) do
		for _, diff in ipairs(file.diffs) do
			table.insert(all_diffs, diff)
		end
	end

	return all_diffs
end

function M.clear_batch()
	-- Clear all the diff instances
	local all_diffs = M.get_diffs()
	for _, diff in ipairs(all_diffs) do
		diff.clear()
	end

	-- Wipe table
	M.current_batch = {}
end

function M.get_batch()
	return M.current_batch
end

function M.get_diffs_from_file(file)
	return M.current_batch[file] or {}
end

return M
