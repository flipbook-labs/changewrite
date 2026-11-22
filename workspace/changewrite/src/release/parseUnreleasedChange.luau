local semver = require("@workspace/semver")

local constants = require("@root/release/constants")
local parseFrontmatter = require("@root/release/parseFrontmatter")
local stripQuotes = require("@root/release/stripQuotes")
local types = require("@root/release/types")

local parseVersionComponent = semver.parseVersionComponent

type ChangeFlag = types.ChangeFlag
type ParsedUnreleasedChange = types.ParsedUnreleasedChange

local DEFAULT_CATEGORY = "Changes"

-- `categories` and `kinds` are the lists `changewrite.toml` configures. Once a
-- repo configures either list, every entry has to pick a value from it, so no
-- entry renders without a heading or a chip. Without a `categories` list, an
-- entry may leave out its category and lands under Changes. A repo that
-- configures no kinds can't use the field.
local function parseUnreleasedChange(text: string, categories: { string }?, kinds: { string }?): ParsedUnreleasedChange
	local frontmatter = parseFrontmatter(text, "Unreleased change")
	local fields = frontmatter.fields
	local body = frontmatter.body
	assert(body ~= "", "Unreleased change has no body")

	local bump = parseVersionComponent(fields.bump)
	local category = fields.category
	local hasCategory = category ~= nil and category ~= ""
	if categories then
		assert(hasCategory, `Unreleased change has no category. Expected one of: {table.concat(categories, ", ")}`)
	end
	if not hasCategory then
		category = DEFAULT_CATEGORY
	end
	if categories then
		assert(
			table.find(categories, category) ~= nil,
			`Unreleased change category "{category}" is not configured. Expected one of: {table.concat(categories, ", ")}`
		)
	end

	local kind: string? = nil
	local configuredKinds = kinds or {}
	if fields.kind == nil or fields.kind == "" then
		assert(
			#configuredKinds == 0,
			`Unreleased change has no kind. Expected one of: {table.concat(configuredKinds, ", ")}`
		)
	else
		local configured = configuredKinds
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
