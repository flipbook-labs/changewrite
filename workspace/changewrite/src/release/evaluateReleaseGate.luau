export type GateInput = {
	-- The version currently in the configured source of truth.
	version: string,
	-- Force publishing the current version regardless of repo state.
	forcePublish: boolean,
	-- Whether a `v{version}` tag already exists.
	tagExists: boolean,
	-- Whether any unreleased changes are waiting to be released.
	hasUnreleasedChanges: boolean,
	-- Whether the changelog already documents the current version, i.e. a release
	-- was prepared for it. This is what distinguishes a prepared-but-untagged
	-- release from a pristine repo that merely carries an untagged version.
	releasePrepared: boolean,
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

	-- An untagged version only means "publish me" when a release was actually
	-- prepared for it (the changelog documents it). A pristine repo carrying an
	-- untagged version has no such section, so it stays quiet instead of minting
	-- a release nobody asked for.
	if not input.tagExists and input.releasePrepared then
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
