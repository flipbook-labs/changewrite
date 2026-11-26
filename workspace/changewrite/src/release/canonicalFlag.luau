local constants = require("@root/release/constants")

--[[
	Flags used to be written in lowercase, such as `breaking`, and are now
	written as `Breaking`. This returns a known flag's current spelling when the
	given name matches it in any case. Anything else comes back as written, so
	whatever reads it next reports it as an unknown flag with the list of known
	ones.
]]
local function canonicalFlag(flag: string): string
	for _, known in constants.CHANGE_FLAGS do
		if known:lower() == flag:lower() then
			return known
		end
	end
	return flag
end

return canonicalFlag
