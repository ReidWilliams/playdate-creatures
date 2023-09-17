import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics
math.randomseed(2018)

-- globals
-- Define constants for creature parts and scroll mode
HEAD =  1
BODY =  2
FEET =  3
ALL =   0
FAVORITES = 4

-- Total images for each part
NUMPARTS = {
   [HEAD] = 7,
   [BODY] = 7,
   [FEET] = 6
}

local helpers = import("helpers")

-- comment out to remove testing
local tests = import("tests")
tests.test(helpers)

-- List of available sprites for each part
local images = {
    [HEAD] = {},
    [BODY] = {},
    [FEET] = {}
}

-- Creatures 1 .. N are defined as the creature with 
-- {head: 1, body: 1, feet:1}, {head: 1, body: 1, feet:2},
-- ... {head: 1, body: 2, feet:1} ... {head: M, body: N, feet:P}
-- This "native" creature order is randomized so that when scrolling
-- through the above pattern isn't noticeable.
-- randomizedCreatures has one entry per creature, with values corresponcing
-- to each create.

local randomizedCreatures = helpers.randomizeCreatures(NUMPARTS)
local randomizedCreaturesIndex = 1

-- list of favorite creates. Values are "natural" creature numbers
local favoriteCreatures = playdate.datastore.read() or {}
local favoriteCreaturesIndex = 1

local scrollMode = ALL -- scroll by head, body, feet, all at once

-- Load creature parts into memory
for i = 1, NUMPARTS[HEAD] do
    images[HEAD][i] = gfx.image.new("images/head/" .. i .. ".png")
end

for i = 1, NUMPARTS[BODY] do
    images[BODY][i] = gfx.image.new("images/body/" .. i .. ".png")
end

for i = 1, NUMPARTS[FEET] do
    images[FEET][i] = gfx.image.new("images/feet/" .. i .. ".png")
end

-- load other images into memory
local circleImage = gfx.image.new("images/ui/circle.png")
local heartOpenImage = gfx.image.new("images/ui/heart-open.png")
local heartFilledImage = gfx.image.new("images/ui/heart-filled.png")

-- load click sound
local crankSound = playdate.sound.sampleplayer.new("/sounds/click.wav")
local isPlayingCrankSound = false
crankSound:setFinishCallback(
   function()
      isPlayingCrankSound = false
   end
)   

-- load other sounds
local cursorSound = playdate.sound.sampleplayer.new("/sounds/beep.wav")
local allModeSound = playdate.sound.sampleplayer.new("/sounds/robo.wav")

function playCrankSound() 
   if not isPlayingCrankSound then
      isPlayingCrankSound = true
      crankSound:play(1, 5.0)
   end
end

function playdate.leftButtonDown()
   setScrollMode(scrollMode + 1)
end

function playdate.upButtonDown()
   updateCreature(-1)
end

function playdate.rightButtonDown()
   setScrollMode(scrollMode - 1)
end

function playdate.downButtonDown()
   updateCreature(1)
end

function playdate.AButtonDown()
    favoriteCreature()
end

function playdate.BButtonDown()
    favoriteCreature()
end

-- adds or removes
function favoriteCreature()
    local creature = randomizedCreatures[randomizedCreaturesIndex]
    local pos = helpers.indexOf(favoriteCreatures, creature)
    
    if pos then
        table.remove(favoriteCreatures, pos)
    else
        table.insert(favoriteCreatures, creature)
    end
    
    playdate.datastore.write(favoriteCreatures)
end
   
function setScrollMode(m)
   if m < 0 then 
      scrollMode = 4
   elseif m > 4 then 
      scrollMode = 0 
   else
      scrollMode = m
   end
   
   if scrollMode == ALL then
      allModeSound:play(1)
   else
      cursorSound:play(1)
   end
end 

function updateCreature(delta)
   if delta == 0 then return end
   playCrankSound()
   
   if scrollMode == FAVORITES then
        if #favoriteCreatures == 0 then return end
       
        favoriteCreaturesIndex = helpers.mod(favoriteCreaturesIndex + delta, #favoriteCreatures)
        local creature = favoriteCreatures[favoriteCreaturesIndex]
        
        -- keep index of randomized creatures point to the same creature
        randomizedCreaturesIndex = helpers.indexOf(randomizedCreatures, creature)
        return
    end   
      
   if scrollMode == ALL then
      randomizedCreaturesIndex = helpers.mod(randomizedCreaturesIndex + delta, #randomizedCreatures)
      print("creature: " .. randomizedCreatures[randomizedCreaturesIndex])
      print("parts: ")
      printTable(helpers.partsIndices(randomizedCreatures[randomizedCreaturesIndex], NUMPARTS))
      return 
   end
   
   -- scrollmode is HEAD, BODY, or FEET
   local parts = helpers.partsIndices(randomizedCreatures[randomizedCreaturesIndex], NUMPARTS) 
   parts[scrollMode] = helpers.mod(parts[scrollMode] + delta, NUMPARTS[scrollMode])
   
   -- update randomizedCreaturesIndex to match change to head, body, or foot index
   local creature = helpers.creatureFromParts(parts, NUMPARTS)

   randomizedCreaturesIndex = helpers.indexOf(randomizedCreatures, creature)
   
   print("creature: " .. randomizedCreatures[randomizedCreaturesIndex])
   print("parts: ")
   printTable(helpers.partsIndices(randomizedCreatures[randomizedCreaturesIndex], NUMPARTS))
end

-- Function to render the creature
function renderCreature(x, y)
   local partIndex = helpers.partsIndices(randomizedCreatures[randomizedCreaturesIndex], NUMPARTS)
    -- Render each part of the creature
    images[HEAD][partIndex[HEAD]]:draw(x + 266, y)
    images[BODY][partIndex[BODY]]:draw(x + 133, y)
    images[FEET][partIndex[FEET]]:draw(x,       y)
end

function renderUI()
   -- when scrollmode is ALL, draw circles next to head, body, feet
   if scrollMode == HEAD or scrollMode == ALL then
      circleImage:draw(327, -1)
   end
   
   if scrollMode == BODY or scrollMode == ALL then
      circleImage:draw(194, -1)
   end
   
   if scrollMode == FEET or scrollMode == ALL then
      circleImage:draw(69, -1)
   end
   
   if scrollMode == FAVORITES then
      circleImage:draw(8, -1)
   end
   
   if helpers.indexOf(favoriteCreatures, randomizedCreatures[randomizedCreaturesIndex]) then
       heartFilledImage:draw(7, 8)
   else
       heartOpenImage:draw(7, 8)
   end
end

-- Main game loop
function playdate.update()
   updateCreature(playdate.getCrankTicks(6))
      
    -- Render the creature at a specific position
    renderCreature(0, 0)
    renderUI()
end

