export type ChangeFlag = "Breaking" | "Deprecated" | "Security"

local ChangeFlag = table.freeze({
	Breaking = "Breaking" :: ChangeFlag,
	Deprecated = "Deprecated" :: ChangeFlag,
	Security = "Security" :: ChangeFlag,
})

return ChangeFlag
