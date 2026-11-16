local test = require("@std/test")

local applyUnlock = require("@root/release/applyUnlock")
local buildStatusArgs = require("@root/release/buildStatusArgs")

-- Each read returns the next head in order, standing in for pushes landing on
-- the base branch between reads.
local function createBaseHeads(heads: { string }): (() -> string, () -> number)
	local reads = 0
	local function readBaseHead(): string
		reads += 1
		return heads[math.min(reads, #heads)]
	end
	local function countReads(): number
		return reads
	end
	return readBaseHead, countReads
end

test.suite("applyUnlock", function(suite)
	suite:case("unlocks without reading the base when no base commit is given", function(assert)
		local posted: { buildStatusArgs.State } = {}
		local readBaseHead, countReads = createBaseHeads({ "main1" })

		applyUnlock({
			sha = "publish1",
			isExplicitSha = false,
			readBaseHead = readBaseHead,
			post = function(state)
				table.insert(posted, state)
			end,
		})

		assert.eq(table.concat(posted, ","), "success")
		assert.eq(countReads(), 0)
	end)

	suite:case("posts nothing for the publish head", function(assert)
		local posted: { buildStatusArgs.State } = {}
		local readBaseHead = createBaseHeads({ "main1" })

		applyUnlock({
			sha = "publish1",
			isExplicitSha = true,
			publishHead = "publish1",
			baseSha = "main1",
			readBaseHead = readBaseHead,
			post = function(state)
				table.insert(posted, state)
			end,
		})

		assert.eq(#posted, 0)
	end)

	suite:case("stays unlocked when the base holds through the unlock", function(assert)
		local posted: { buildStatusArgs.State } = {}
		local readBaseHead, countReads = createBaseHeads({ "main1", "main1" })

		applyUnlock({
			sha = "publish1",
			isExplicitSha = false,
			baseSha = "main1",
			readBaseHead = readBaseHead,
			post = function(state)
				table.insert(posted, state)
			end,
		})

		assert.eq(table.concat(posted, ","), "success")
		assert.eq(countReads(), 2)
	end)

	suite:case("locks without unlocking when the base already moved", function(assert)
		local posted: { buildStatusArgs.State } = {}
		local readBaseHead = createBaseHeads({ "main2" })

		applyUnlock({
			sha = "publish1",
			isExplicitSha = false,
			baseSha = "main1",
			readBaseHead = readBaseHead,
			post = function(state)
				table.insert(posted, state)
			end,
		})

		assert.eq(table.concat(posted, ","), "failure")
	end)

	suite:case("locks again when the base moves between the check and the unlock", function(assert)
		local posted: { buildStatusArgs.State } = {}
		local readBaseHead = createBaseHeads({ "main1", "main2" })

		applyUnlock({
			sha = "publish1",
			isExplicitSha = false,
			baseSha = "main1",
			readBaseHead = readBaseHead,
			post = function(state)
				table.insert(posted, state)
			end,
		})

		assert.eq(table.concat(posted, ","), "success,failure")
	end)
end)
