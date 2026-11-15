local constants = require("@root/release/constants")
local parseFrontmatter = require("@root/release/parseFrontmatter")
local parseVersionComponent = require("@root/semver/parseVersionComponent")
local stripQuotes = require("@root/release/stripQuotes")
local types = require("@root/release/types")

type ChangeFlag = types.ChangeFlag
type ParsedUnreleasedChange = types.ParsedUnreleasedChange

local DEFAULT_CATEGORY = "Changes"

-- `kinds` lists the kinds `changewrite.toml` configures. A repo that configures
-- none can't use the field.
local function parseUnreleasedChange(text: string, categories: { string }?, kinds: { string }?): ParsedUnreleasedChange
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

	local kind: string? = nil
	if fields.kind ~= nil and fields.kind ~= "" then
		local configured = kinds or {}
		assert(
			table.find(configured, fields.kind) ~= nil,
			if #configured == 0
				then `Unreleased change kind "{fields.kind}" is not configured. Add a [kind.{fields.kind}] table to changewrite.toml`
				else `Unreleased change kind "{fields.kind}" is not configured. Expected one of: {table.concat(
					configured,
					", "
				)}`
		)
		kind = fields.kind
	end

	-- Flags are written as a comma-separated list, with or without the square
	-- brackets of a YAML flow sequence: `flags: breaking, security` or `flags: [breaking]`.
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
