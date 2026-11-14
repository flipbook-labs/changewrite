local FlipbookBatteries = require("@pkg/flipbook-batteries@v0.12.0")

local run = FlipbookBatteries.run

run("stylua", { "-c", "src", "libs", ".lute", "assets" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
	"libs",
})
