local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@batteries/richterm")

local chipConstants = require("@root/chips/constants")
local chipDrawing = require("@root/chips/chipDrawing")
local chipLock = require("@root/chips/chipLock")
local findStaleChipAssets = require("@root/chips/findStaleChipAssets")
local generateChips = require("@root/chips/generateChips")
local getAssetsDir = require("@root/chips/getAssetsDir")
local getChipFont = require("@root/chips/getChipFont")
local planChips = require("@root/chips/planChips")
local readChipStyles = require("@root/chips/readChipStyles")
local types = require("@root/cli/types")

local title = "generate"
local summary = "Draw the release-notes chips for the kinds and flags in changewrite.toml."

local parser = cli.parser()
parser:add("check", "flag", {
	help = "Fail if the generated files don't match changewrite.toml, instead of writing them.",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

local function check()
	local stale = findStaleChipAssets()
	if #stale == 0 then
		print("Chips match changewrite.toml.")
		return
	end
	print(richterm.red("Chips don't match changewrite.toml. Run `changewrite generate` and commit the result:"))
	for _, line in stale do
		print(`  • {line}`)
	end
	process.exit(1)
end

-- Files for an earlier look of a chip stay in place, because past releases
-- still link to them.
local function generate()
	if parser:has("check") then
		check()
		return
	end

	local planned = planChips(readChipStyles())
	local specs = {}
	for _, chip in planned do
		table.insert(specs, chip.spec)
	end

	local dir = getAssetsDir()
	if not fs.exists(dir) then
		fs.createDirectory(dir, { makeParents = true })
	end

	local written = 0
	for _, file in generateChips(getChipFont(), specs, chipDrawing.metrics, chipDrawing.pngScale) do
		local target = path.join(dir, file.name)
		if not fs.exists(target) or fs.readFileToString(target) ~= file.contents then
			fs.writeStringToFile(target, file.contents)
			written += 1
		end
	end
	fs.writeStringToFile(path.join(dir, chipConstants.LOCKFILE_NAME), chipLock.serialize(planned))

	print(`Generated {#planned} chips in {dir} ({written} files written).`)
end

local command: types.Command = {
	run = generate,
	title = title,
	summary = summary,
	parser = parser,
}

return command
