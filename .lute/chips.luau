local cli = require("@batteries/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local truetype = require("@libs/truetype")

local chipData = require("@repo/assets/chips/chips")
local generateChips = require("@root/chips/generateChips")

local parser = cli.parser()
parser:add("check", "flag", {
	help = "Fail if the committed chips differ from what the data generates, instead of writing them.",
})
parser:parse({ ... })

local font = truetype.readTrueTypeFont(buffer.fromstring(fs.readFileToString(chipData.font)))
local files = generateChips(font, chipData.chips, chipData.metrics, chipData.pngScale)
local outputDir = path.join("assets", "chips", chipData.version)

if parser:has("check") then
	local stale: { string } = {}
	for _, file in files do
		local target = path.join(outputDir, file.name)
		if not fs.exists(target) or fs.readFileToString(target) ~= file.contents then
			table.insert(stale, tostring(target))
		end
	end
	if #stale > 0 then
		print("These chips don't match assets/chips/chips.luau. Run `lute run chips` and commit the result:")
		for _, target in stale do
			print(`  {target}`)
		end
		process.exit(1)
	end
	print(`All {#files} chip files match their data.`)
	return
end

if not fs.exists(outputDir) then
	fs.createDirectory(outputDir, { makeParents = true })
end
for _, file in files do
	fs.writeStringToFile(path.join(outputDir, file.name), file.contents)
end
print(`Wrote {#files} chip files to {outputDir}.`)
