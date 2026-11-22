local fs = require("@std/fs")
local path = require("@std/path")

local constants = require("@root/release/constants")
local convertTomlConfig = require("@root/release/convertTomlConfig")
local parseConfig = require("@root/release/parseConfig")

-- Replaces a changewrite.toml with the same settings in changewrite.luau. The
-- TOML file's comments are dropped. Does nothing when there's no
-- changewrite.toml.
local function convertTomlConfigFile()
	local legacyPath = path.resolve(constants.LEGACY_CONFIG_FILE)
	if not fs.exists(legacyPath) then
		return
	end
	local target = path.resolve(constants.CONFIG_FILE)
	assert(
		not fs.exists(target),
		`Can't convert {constants.LEGACY_CONFIG_FILE}: {constants.CONFIG_FILE} already exists. Delete whichever is out of date.`
	)

	local converted = convertTomlConfig(fs.readFileToString(legacyPath))
	-- Loading the result catches a setting Changewrite doesn't read before the
	-- TOML file is gone.
	local success, err = pcall(parseConfig, converted)
	assert(success, `Can't convert {constants.LEGACY_CONFIG_FILE}: {err}`)

	fs.writeStringToFile(target, converted)
	fs.remove(legacyPath)
	print(`Converted {constants.LEGACY_CONFIG_FILE} to {constants.CONFIG_FILE}. Comments in it weren't carried over.`)
end

return convertTomlConfigFile
