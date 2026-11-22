local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag

local ChangeFlag = table.freeze({
	Breaking = "Breaking" :: ChangeFlag,
	Deprecated = "Deprecated" :: ChangeFlag,
	Security = "Security" :: ChangeFlag,
})

return ChangeFlag
