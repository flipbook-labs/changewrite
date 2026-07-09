local createPublishLockCommand = require("@root/release/createPublishLockCommand")

return createPublishLockCommand({
	title = "unlock",
	summary = "Unlock the publish PR to reenable merging.",
	state = "success",
})
