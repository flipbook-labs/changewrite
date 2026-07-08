return {
	package = {
		name = "changewrite",
		version = "0.5.0",
		dependencies = {
			["flipbook-batteries"] = {
				rev = "v0.12.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			["lute"] = {
				rev = "v1.0.1-nightly.20260701",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
		},
		-- AgentSkills is agent guidance (markdown skills), not runtime Luau. As a
		-- dev dependency it installs into ~/.loom/store for agents to read but is
		-- kept out of the packages/ vendor step (see .lute/install.luau) so it is
		-- not bundled into the binary. Bump `rev` in lockstep with the
		-- AgentSkills@<version> paths documented in AGENTS.md.
		dev_dependencies = {
			["AgentSkills"] = {
				rev = "v0.2.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
