local function readOptionalString(value: unknown): string?
	return if typeof(value) == "string" then value else nil
end

return readOptionalString
