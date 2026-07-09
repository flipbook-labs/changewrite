local makeMergeLockCommand = require("@root/cli/commands/mergeLock")

return makeMergeLockCommand({
	title = "unlock",
	summary = "Unlock the publish PR by passing its merge-lock commit status.",
	state = "success",
})
