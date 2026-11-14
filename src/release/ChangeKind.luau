local types = require("@root/release/types")

type ChangeKind = types.ChangeKind

local ChangeKind = table.freeze({
	New = "new" :: ChangeKind,
	Improved = "improved" :: ChangeKind,
	Fixed = "fixed" :: ChangeKind,
	Breaking = "breaking" :: ChangeKind,
})

return ChangeKind
