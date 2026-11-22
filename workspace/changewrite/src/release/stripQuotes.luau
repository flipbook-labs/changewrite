local function stripQuotes(value: string): string
	local doubleQuoted = value:match('^"(.*)"$')
	if doubleQuoted then
		return doubleQuoted
	end
	local singleQuoted = value:match("^'(.*)'$")
	if singleQuoted then
		return singleQuoted
	end
	return value
end

return stripQuotes
