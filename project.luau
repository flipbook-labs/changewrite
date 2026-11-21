local path = require("@std/path")

local CHANGEWRITE_PATH = path.resolve("workspace/changewrite")

return {
	BUILD_PATH = path.resolve("build"),
	BUILD_OUTPUT = path.resolve("build/changewrite"),
	CHANGEWRITE_PATH = CHANGEWRITE_PATH,
	CHANGEWRITE_ENTRY = path.join(CHANGEWRITE_PATH, "cli.luau"),
}
