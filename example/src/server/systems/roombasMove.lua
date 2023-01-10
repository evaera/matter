local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)

local function roombasMove(world)
	local targets = {}
	for _, model in world:query(Components.Model, Components.Target) do
		table.insert(targets, model.model.PrimaryPart.CFrame.p)
	end

	for id, roomba, charge, model in world:query(Components.Roomba, Components.Charge, Components.Model) do
		if charge.charge <= 0 then
			continue
		end

		local closestPosition, closestDistance
		local currentPosition = model.model.PrimaryPart.CFrame.p

		for _, target in ipairs(targets) do
			local distance = (currentPosition - target).magnitude
			if not closestPosition or distance < closestDistance then
				closestPosition = target
				closestDistance = distance
			end
		end

		if closestPosition then
			local body = model.model.Roomba
			local force = body:GetMass() * 20

			if closestDistance < 4 then
				force = 0
			end

			local lookVector = body.CFrame.LookVector
			local desiredLookVector = (closestPosition - currentPosition).unit

			force = force * lookVector:Dot(desiredLookVector)
			body.VectorForce.Force = Vector3.new(force, 0, 0)

			local absoluteAngle = math.atan2(desiredLookVector.Z, desiredLookVector.X)
			local roombaAngle = math.atan2(lookVector.Z, lookVector.X)

			local angle = math.deg(absoluteAngle - roombaAngle)

			angle = angle % 360
			angle = (angle + 360) % 360
			if angle > 180 then
				angle -= 360
			end

			local angularVelocity = body.AssemblyAngularVelocity

			local sign = math.sign(angle)
			local motor = math.sqrt(math.abs(angle)) * sign * -1 * 20
			local friction = angularVelocity.Y * -12
			local torque = body:GetMass() * (motor + friction)

			body.Torque.Torque = Vector3.new(0, torque, 0)
		end
	end
end

return roombasMove
