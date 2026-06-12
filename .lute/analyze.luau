local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.9.0")

local run = FlipbookBatteries.run

run("stylua", { "-c", "src", ".lute" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
})
