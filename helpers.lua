local M = {} -- module
    
-- return index of head, body, feet given creature
-- and total number of each part
function M.partsIndices(creature, nparts)
   local bodyAndFeet =  nparts[BODY] * nparts[FEET]
    
   local headIndex = M.mod(math.ceil(creature/bodyAndFeet), nparts[HEAD]) 
   local bodyIndex = M.mod(math.ceil(creature/nparts[FEET]), nparts[BODY])
   local feetIndex = M.mod(creature, nparts[FEET])

   return {
       [HEAD] = headIndex,
       [BODY] = bodyIndex,
       [FEET] = feetIndex
   }
end

-- get creature index from parts indices
function M.creatureFromParts(parts, nparts)
    local index = ((parts[HEAD]-1) * nparts[BODY] * nparts[FEET])
        + ((parts[BODY]-1) * nparts[FEET])
        + parts[FEET]
   return index
end

-- Create random order for all creatures. This makes a randomized list of all creatures that you can
-- scroll through with the crank, but it's consistent when you scroll forwards / backwards.
-- Takes table with number of parts for head, body, feet
function M.randomizeCreatures(nparts)    
    local totalCreatures = nparts[HEAD] * nparts[BODY] * nparts[FEET]
    local numbers = {}
    local creatureOrder = {}
   
    for i = 1, totalCreatures do
        numbers[i] = i
    end
     
    for i = totalCreatures, 1, -1 do
        local r = math.random(i) -- generate a random index
        table.insert(creatureOrder, numbers[r])
        table.remove(numbers, r) -- remove the number from the original list
    end
   
    return creatureOrder
end

-- Takes mod of N that is friendly to Lua's 1-indexed arrays.
-- For instance mod(1, 3) = 1; mod(2, 3) = 2; mod(3, 3) = 3; mod(4, 3) = 1
-- Assume n is not 0
function M.mod(n, max)
    return ((n-1) % max) + 1
end

function M.indexOf(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

return M
