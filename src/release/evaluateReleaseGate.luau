local placeholderVersion = require("@root/release/placeholderVersion")

export type GateInput = {
	-- The version currently in the configured source of truth.
	version: string,
	-- Force publishing the current version regardless of repo state.
	forcePublish: boolean,
	-- Whether a `v{version}` tag already exists.
	tagExists: boolean,
	-- Whether any unreleased changes are waiting to be released.
	hasUnreleasedChanges: boolean,
}

export type GateResult = {
	version: string,
	-- This run should tag + draft a release for the current version.
	shouldPublish: boolean,
	-- There are pending unreleased changes, so a publish PR can be prepared.
	hasChanges: boolean,
}

local function evaluateReleaseGate(input: GateInput): GateResult
	if input.forcePublish then
		return {
			version = input.version,
			shouldPublish = true,
			hasChanges = false,
		}
	end

	if input.hasUnreleasedChanges then
		return {
			version = input.version,
			shouldPublish = false,
			hasChanges = true,
		}
	end

	-- The 0.0.0 placeholder means nothing has been released yet; publishing it
	-- would mint a meaningless v0.0.0 release, so wait for a change entry to
	-- bump it instead.
	if not input.tagExists and input.version ~= placeholderVersion then
		return {
			version = input.version,
			shouldPublish = true,
			hasChanges = false,
		}
	end

	return {
		version = input.version,
		shouldPublish = false,
		hasChanges = false,
	}
end

return evaluateReleaseGate
