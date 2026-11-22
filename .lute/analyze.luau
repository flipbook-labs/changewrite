local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")

local run = FlipbookBatteries.run

run("stylua", { "-c", "workspace", ".lute" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"workspace/changewrite/src",
	"workspace/png",
	"workspace/semver",
	"workspace/truetype",
	"workspace/vector",
})
