local formatNumber = require("@root/chips/formatNumber")
local types = require("@root/chips/types")

type Path = types.Path

local function pathToSvgData(path: Path): string
	local parts: { string } = {}
	for _, command in path do
		if command.op == "M" or command.op == "L" then
			table.insert(parts, `{command.op}{formatNumber(command.x)} {formatNumber(command.y)}`)
		elseif command.op == "Q" then
			table.insert(
				parts,
				`Q{formatNumber(command.x1)} {formatNumber(command.y1)} {formatNumber(command.x)} {formatNumber(
					command.y
				)}`
			)
		elseif command.op == "C" then
			table.insert(
				parts,
				`C{formatNumber(command.x1)} {formatNumber(command.y1)} {formatNumber(command.x2)} {formatNumber(
					command.y2
				)} {formatNumber(command.x)} {formatNumber(command.y)}`
			)
		else
			table.insert(parts, "Z")
		end
	end
	return table.concat(parts)
end

return pathToSvgData
