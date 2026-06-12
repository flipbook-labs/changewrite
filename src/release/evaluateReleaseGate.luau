-- Pure decision logic for the release gate. Given the repo's state (current
-- version, whether it's been tagged, and how many commits sit on top of that
-- tag) it decides whether this run should publish the current version or leave
-- it for a future publish PR. Kept free of IO so it can be unit tested; the
-- `release gate` command feeds it real git queries.

export type GateInput = {
	-- The version currently in the configured source of truth.
	version: string,
	-- Force publishing the current version regardless of repo state.
	forcePublish: boolean,
	-- Whether a `v{version}` tag already exists.
	tagExists: boolean,
	-- Number of commits since the `v{version}` tag (0 when untagged).
	commitsSinceTag: number,
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

	-- The current version has no matching tag yet: a publish PR merged (the bump
	-- landed) but nothing has been released, so publish it.
	if not input.tagExists then
		return {
			version = input.version,
			shouldPublish = true,
			hasChanges = false,
		}
	end

	-- The current version is already released. Surface whether there are commits
	-- since its tag so a new publish PR can be prepared.
	return {
		version = input.version,
		shouldPublish = false,
		hasChanges = input.commitsSinceTag > 0,
	}
end

return evaluateReleaseGate
