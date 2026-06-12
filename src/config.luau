local process = require("@std/process")

return {
	gitCmd = process.env.CHANGEWRITE_GIT_CMD or "git",
	ghCmd = process.env.CHANGEWRITE_GH_CMD or "gh",
	gitCliffCmd = process.env.CHANGEWRITE_GIT_CLIFF_CMD or "git-cliff",
}
