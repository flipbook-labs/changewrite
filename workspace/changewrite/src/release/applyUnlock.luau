local buildStatusArgs = require("@root/release/buildStatusArgs")
local resolveUnlockState = require("@root/release/resolveUnlockState")

export type UnlockRequest = {
	sha: string,
	isExplicitSha: boolean,
	publishHead: string?,
	baseSha: string?,
	readBaseHead: () -> string,
	post: (buildStatusArgs.State) -> (),
}

local function applyUnlock(request: UnlockRequest)
	local function resolveState(): buildStatusArgs.State?
		return resolveUnlockState({
			sha = request.sha,
			isExplicitSha = request.isExplicitSha,
			publishHead = request.publishHead,
			baseSha = request.baseSha,
			baseHead = if request.baseSha then request.readBaseHead() else nil,
		})
	end

	local state = resolveState()
	if not state then
		return
	end
	request.post(state)

	-- A push that lands after the first read starts a newer run whose lock can
	-- post before this unlock, which would overwrite it. That push moved the
	-- base before its lock posted, so reading the base again after unlocking
	-- catches it.
	if state == "success" and request.baseSha and resolveState() == "failure" then
		request.post("failure")
	end
end

return applyUnlock
