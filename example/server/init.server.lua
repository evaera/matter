local ReplicatedStorage = game:GetService("ReplicatedStorage")
local start = require(ReplicatedStorage.Game.start)
local setupTags = require(ReplicatedStorage.Game.setupTags)

local world = start(script.systems)

setupTags(world)
