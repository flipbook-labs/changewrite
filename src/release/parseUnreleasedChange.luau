local constants = require("@root/release/constants")
local parseFrontmatter = require("@root/release/parseFrontmatter")
local parseVersionComponent = require("@root/semver/parseVersionComponent")
local stripQuotes = require("@root/release/stripQuotes")
local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag
type ChangeKind = types.ChangeKind
type ParsedUnreleasedChange = types.ParsedUnreleasedChange

local DEFAULT_CATEGORY = "Changes"

local function parseUnreleasedChange(text: string, categories: { string }?): ParsedUnreleasedChange
	local frontmatter = parseFrontmatter(text, "Unreleased change")
	local fields = frontmatter.fields
	local body = frontmatter.body
	assert(body ~= "", "Unreleased change has no body")

	local bump = parseVersionComponent(fields.bump)
	local category = fields.category
	if category == nil or category == "" then
		category = DEFAULT_CATEGORY
	end
	if categories then
		assert(
			table.find(categories, category) ~= nil,
			`Unreleased change category "{category}" is not configured. Expected one of: {table.concat(categories, ", ")}`
		)
	end

	local kind: ChangeKind? = nil
	if fields.kind ~= nil and fields.kind ~= "" then
		assert(
			table.find(constants.CHANGE_KINDS, fields.kind) ~= nil,
			`Unreleased change kind "{fields.kind}" is not supported. Expected one of: {table.concat(
				constants.CHANGE_KINDS,
				", "
			)}`
		)
		kind = fields.kind :: ChangeKind
	end

	-- Flags are written as a comma-separated list, with or without the square
	-- brackets of a YAML flow sequence: `flags: api, security` or `flags: [api]`.
	local flags: { ChangeFlag } = {}
	local flagList = (fields.flags or ""):match("^%[(.*)%]$") or fields.flags or ""
	for _, rawFlag in flagList:split(",") do
		local flag = stripQuotes((rawFlag:gsub("^%s+", ""):gsub("%s+$", "")))
		if flag == "" then
			continue
		end
		assert(
			table.find(constants.CHANGE_FLAGS, flag) ~= nil,
			`Unreleased change flag "{flag}" is not supported. Expected any of: {table.concat(
				constants.CHANGE_FLAGS,
				", "
			)}`
		)
		if table.find(flags, flag :: ChangeFlag) == nil then
			table.insert(flags, flag :: ChangeFlag)
		end
	end

	local highlight = fields.highlight
	if highlight == "" then
		highlight = nil
	end

	local pr: number? = nil
	if fields.pr ~= nil and fields.pr ~= "" then
		local digits = fields.pr:match("^#?(%d+)$")
		assert(digits, `Unreleased change pr "{fields.pr}" must be a pull request number`)
		pr = tonumber(digits)
	end

	return {
		bump = bump,
		category = category,
		body = body,
		kind = kind,
		flags = flags,
		highlight = highlight,
		pr = pr,
	}
end

return parseUnreleasedChange
