local root_markers_with_field =
	require("lib.root-markers-with-field").root_markers_with_field
local M = {}

function M.insert_package_json(root_files, field, fname)
	return root_markers_with_field(
		root_files,
		{ "package.json", "package.json5" },
		field,
		fname
	)
end

return M
