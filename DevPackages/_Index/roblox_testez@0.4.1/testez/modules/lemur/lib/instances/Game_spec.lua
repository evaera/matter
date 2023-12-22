local Game = import("./Game")
local typeof = import("../functions/typeof")

describe("instances.Game", function()
	it("should instantiate", function()
		local instance = Game:new()

		assert.not_nil(instance)
	end)

	describe("GetService", function()
		it("should have GetService", function()
			local instance = Game:new()

			local ReplicatedStorage = instance:GetService("ReplicatedStorage")

			assert.not_nil(ReplicatedStorage)
			assert.equal(instance.ReplicatedStorage, ReplicatedStorage)
		end)

		it("should throw when given invalid service names", function()
			local instance = Game:new()

			assert.has.errors(function()
				instance:GetService("SOMETHING THAT WILL NEVER EXIST")
			end)
		end)
	end)

	it("should have properties defined", function()
		local instance = Game:new()

		assert.equal(typeof(instance.CreatorId), "number")
		assert.equal(typeof(instance.CreatorType), "EnumItem")
		assert.equal(typeof(instance.GameId), "number")
		assert.equal(typeof(instance.JobId), "string")
		assert.equal(typeof(instance.PlaceId), "number")
		assert.equal(typeof(instance.PlaceVersion), "number")
		assert.equal(typeof(instance.VIPServerId), "string")
		assert.equal(typeof(instance.VIPServerOwnerId), "number")
	end)
end)