local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag

local ChangeFlag = table.freeze({
	Breaking = "breaking" :: ChangeFlag,
	Deprecated = "deprecated" :: ChangeFlag,
	Security = "security" :: ChangeFlag,
})

return ChangeFlag
