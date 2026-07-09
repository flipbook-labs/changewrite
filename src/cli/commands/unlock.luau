local createMergeLockCommand = require("@root/release/createMergeLockCommand")

return createMergeLockCommand({
	title = "unlock",
	summary = "Unlock the publish PR to reenable merging.",
	state = "success",
})
