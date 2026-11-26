-- This repository is a Lute package workspace. The manifest has no name or
-- version, so Lute treats it as the workspace's virtual root, which only groups
-- packages and can't be installed itself. Each path dependency is a member: a
-- package in its own `workspace/<name>` folder with its own `pkg.luau`, which
-- declares that package's dependencies. `lute run install` vendors every
-- member's dependencies into this folder's `.lpm/`, so the `.lute` scripts can
-- require them too. `dev_dependencies` here holds what no member needs, like
-- the agent-skills library that agents read and the CodeQuality lint rules.
local function member(name: string)
	return { sourceKind = "path", source = `./workspace/{name}` }
end

return {
	package = {
		dependencies = {
			changewrite = member("changewrite"),
			png = member("png"),
			semver = member("semver"),
			truetype = member("truetype"),
			vector = member("vector"),
		},
		dev_dependencies = {
			["agent-skills"] = {
				rev = "v0.9.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
			["code-quality"] = {
				rev = "v0.8.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/code-quality",
			},
		},
	},
}
