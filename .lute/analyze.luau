local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")

local run = FlipbookBatteries.run

run("stylua", { "-c", "src", "libs", ".lute", "assets" })

run("luau-lsp", {
	"analyze",
	"--settings=./.vscode/settings.json",
	"src",
	"libs",
})
