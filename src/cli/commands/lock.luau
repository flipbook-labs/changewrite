local createMergeLockCommand = require("@root/release/createMergeLockCommand")

return createMergeLockCommand({
	title = "lock",
	summary = "Lock the publish PR to prevent accidental merges while changes are in flight.",
	state = "failure",
})
