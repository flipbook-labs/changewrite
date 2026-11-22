local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

-- The webhook payload GitHub Actions writes for the triggering event, or nil
-- outside Actions.
local function readGithubEvent(): json.Object?
	local eventPath = process.env.GITHUB_EVENT_PATH
	if not eventPath or eventPath == "" or not fs.exists(eventPath) then
		return nil
	end

	return json.asObject(json.deserialize(fs.readFileToString(eventPath)))
end

return readGithubEvent
