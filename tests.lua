local M = {}

function M.test(helpers)	
	print("running unit tests")
	
	assert(helpers.mod(1, 3) == 1)
	assert(helpers.mod(2, 3) == 2)
	assert(helpers.mod(3, 3) == 3)
	assert(helpers.mod(4, 3) == 1)
		
	local nparts = {
	    [HEAD] = 2,
		[BODY] = 3,
		[FEET] = 2
	}
	
	-- utility for checking results
	local function checkIndexResult(result, h, b, f)
		assert(result[HEAD] == h)
		assert(result[BODY] == b)
		assert(result[FEET] == f)
	end
	
	checkIndexResult(helpers.partsIndices(1, nparts), 1, 1, 1)
	checkIndexResult(helpers.partsIndices(2, nparts), 1, 1, 2)
	checkIndexResult(helpers.partsIndices(6, nparts), 1, 3, 2)
	checkIndexResult(helpers.partsIndices(7, nparts), 2, 1, 1)
	checkIndexResult(helpers.partsIndices(12, nparts), 2, 3, 2)
	checkIndexResult(helpers.partsIndices(13, nparts), 1, 1, 1)
	
	local function creature(h, b, f)
		local c = {
			[HEAD] = h,
			[BODY] = b,
			[FEET] = f
		}
		return c
	end
	
	assert(helpers.creatureFromParts(creature(1, 1, 1), nparts) == 1)
	assert(helpers.creatureFromParts(creature(1, 1, 2), nparts) == 2)
	assert(helpers.creatureFromParts(creature(1, 3, 2), nparts) == 6)
	assert(helpers.creatureFromParts(creature(2, 1, 1), nparts) == 7)
	assert(helpers.creatureFromParts(creature(2, 3, 2), nparts) == 12)

	local testTable = {
		[1] = 10,
		[2] = 20,
		[3] = 30
	}
	
	assert(helpers.indexOf(testTable, 10) == 1)
	assert(helpers.indexOf(testTable, 40) == nil)

	print("all tests passed")
end
	
return M



