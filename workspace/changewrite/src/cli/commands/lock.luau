local createPublishLockCommand = require("@root/release/createPublishLockCommand")

return createPublishLockCommand({
	title = "lock",
	summary = "Lock the publish PR to prevent accidental merges while changes are in flight.",
	state = "failure",
})
