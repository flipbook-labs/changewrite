local makeMergeLockCommand = require("@root/cli/commands/mergeLock")

return makeMergeLockCommand({
	title = "lock",
	summary = "Lock the publish PR by failing its merge-lock commit status.",
	state = "failure",
})
