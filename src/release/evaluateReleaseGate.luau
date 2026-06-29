-- Pure decision logic for the release gate. Given the repo's state (current
-- version, whether it's been tagged, and whether any change partials are pending)
-- it decides whether this run should publish the current version or leave it for
-- a future publish PR. Kept free of IO so it can be unit tested; the `gate`
-- command feeds it real git queries and the partial directory.

export type GateInput = {
	-- The version currently in the configured source of truth.
	version: string,
	-- Force publishing the current version regardless of repo state.
	forcePublish: boolean,
	-- Whether a `v{version}` tag already exists.
	tagExists: boolean,
	-- Whether any change partials are waiting to be released.
	hasPartials: boolean,
}

export type GateResult = {
	version: string,
	-- This run should tag + draft a release for the current version.
	shouldPublish: boolean,
	-- There are unreleased commits, so a publish PR can be prepared.
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

	-- There are change partials that haven't been rolled into a version yet, so a
	-- publish PR can be prepared to assemble them. Checked before the untagged
	-- case so the very first release still gets its partials combined into the
	-- initial (untagged) version before it publishes. Trade-off: a
	-- prepared-but-unpublished version can absorb a partial that lands before it
	-- publishes, but the window is tiny since publishing happens on PR merge.
	if input.hasPartials then
		return {
			version = input.version,
			shouldPublish = false,
			hasChanges = true,
		}
	end

	-- No pending partials and no matching tag: a publish PR merged (the bump
	-- landed and its partials were consumed) but nothing has been released yet, so
	-- publish it.
	if not input.tagExists then
		return {
			version = input.version,
			shouldPublish = true,
			hasChanges = false,
		}
	end

	-- The current version is already released and nothing is pending.
	return {
		version = input.version,
		shouldPublish = false,
		hasChanges = false,
	}
end

return evaluateReleaseGate
