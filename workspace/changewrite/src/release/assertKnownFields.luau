local function assertKnownFields(
	value: { [string]: unknown },
	allowedFields: { [string]: boolean },
	context: string
): ()
	for field in value do
		assert(allowedFields[field], `Unknown field "{field}" in {context}`)
	end
end

return assertKnownFields
