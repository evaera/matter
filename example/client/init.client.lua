local ReplicatedStorage = game:GetService("ReplicatedStorage")
local start = require(ReplicatedStorage.Game.start)
local receiveReplication = require(script.receiveReplication)

local world, state = start(ReplicatedStorage.Game.clientSystems)

receiveReplication(world, state)
