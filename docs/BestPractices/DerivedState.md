# Derived state

Oftentimes, games will have state that needs to be affected by multiple, distinct gameplay systems.

For example, imagine you had a game where equipping a heavy weapon lowered your walk speed. There might be other things that affect your walk speed too, like being Poisoned!

So, let's say both equipping the heavy weapon and being poisoned both need to lower your player's walk speed.

Instead of directly controlling the walk speed in the weapon system and then again in the poison system, we should make a dedicated system to manage walk speed.

Let's say that whenever a player is poisoned or has a heavy weapon equipped, our game adds the `Poison` or `HeavyWeapon` components to the player entity. For the sake of this example, we can imagine that each one lowers walk speed by half.

```lua
local affectsWalkSpeed = {Poison, HeavyWeapon}

local function walkSpeed(world)
	for id, player in world:query(Player) do

		local results = {world:get(id, unpack(affectsWalkSpeed))}

		-- NOTE: You can't be tricky by just checking the length of this table!
		-- We MUST iterate over it because the Lua length operator does not work
		-- as you might expect when a table has nil values in it.
		-- See for yourself: Lua says #{nil,nil,nil,1,nil} is 0!

		local modifier = 1

		for _ in results do
			-- For each result, reduce speed by half.
			modifier *= 0.5
		end

		-- The default Roblox walk speed is 16
		local speed = 16 * modifier

		world:insert(id, WalkSpeed({
			speed = speed,
			modifier = modifier,
		}))
	end
end

return walkSpeed
```

By listing out everything that can affect the walk speed in this system, we've created one source of truth for the player's walk speed. Any time there's a bug or something wrong with player movement, just check this one file. It's much easier to track down changes when everything that can affect something is in one place.

The value of the `WalkSpeed` component we use here is completely derived from the state of other components on the entity. This is *derived state*!

Maybe in a separate system, we could update anything with a Model and a WalkSpeed component, perhaps:

```lua

-- Update anything with WalkSpeed and Model (this could be a separate system)
for id, walkSpeed, model in world:query(WalkSpeed, Model) do
	if model.model:FindFirstChild("Humanoid") then
		model.model.Humanoid.WalkSpeed = walkSpeed.speed
	end
end
```