-- Pure decision logic for the release gate. Given the repo's state (current
-- version, whether it's been tagged, and whether any unreleased changes are
-- pending) it decides whether this run should publish the current version or
-- leave it for a future publish PR. Kept free of IO so it can be unit tested; the
-- `gate` command feeds it real git queries and the unreleased-changes directory.

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

	-- There are unreleased changes that haven't been rolled into a version yet, so
	-- a publish PR can be prepared to assemble them. Checked before the untagged
	-- case so the very first release still gets its changes combined into the
	-- initial (untagged) version before it publishes. Trade-off: a
	-- prepared-but-unpublished version can absorb a change that lands before it
	-- publishes, but the window is tiny since publishing happens on PR merge.
	if input.hasUnreleasedChanges then
		return {
			version = input.version,
			shouldPublish = false,
			hasChanges = true,
		}
	end

	-- No pending changes and no matching tag: a publish PR merged (the bump landed
	-- and its changes were consumed) but nothing has been released yet, so publish
	-- it.
	if not input.tagExists then
		return {
			version = input.version,
			shouldPublish = true,
			hasChanges = false,
		}
	end

	-- The current version is already released and no changes are pending.
	return {
		version = input.version,
		shouldPublish = false,
		hasChanges = false,
	}
end

return evaluateReleaseGate
