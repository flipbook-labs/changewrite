local assertKnownFields = require("@root/release/assertKnownFields")

local TARGET_FIELDS: { [string]: boolean } = {
	file = true,
	pattern = true,
}

local function validateVersionTargetFields(value: unknown, context: string): ()
	if typeof(value) == "table" then
		assertKnownFields(value :: { [string]: unknown }, TARGET_FIELDS, context)
	end
end

return validateVersionTargetFields
