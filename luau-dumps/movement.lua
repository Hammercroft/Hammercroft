--!strict

-- Movement Script (WishDir handler) by St0rmCast3r
-- heavily modified from ThanksRoBama's original script
-- Adapted to use WishDir as the sole input

local RunS = game:GetService("RunService")

local player = game.Players.LocalPlayer; assert(player)
local camera = workspace.CurrentCamera

local ACCELERATION = 6 
local AIR_ACCELERATION = 2
local FRICTION = 5
local STOP_SPEED = 7
local JUMP_HEIGHT = 4.8
--local JUMP_COOLDOWN = 0.44
local SPRINT_SPEED_MODIFIER = 1.66
local SPRINT_MODIFY_APPLY_RATE = 0.88
local SPRINT_MODIFY_DECAY_RATE = 2.7
local CROUCH_SPEED_MODIFIER = 0.75
local WATER_SPEED_MODIFIER = 0.88
local WATER_FRICTION = 2.1

--local lastTimeSinceJump = 0

local character = player.Character or player.CharacterAdded:Wait()
local targetMoveVelocity = Vector3.zero
local moveVelocity = Vector3.zero

-- Retrieve our custom values
local wishDir = character:WaitForChild("WishDir") :: Vector3Value
local baseSpeed = character:WaitForChild("BaseMovementSpeed") :: NumberValue
local isSprinting = character:WaitForChild("IsSprinting") :: BoolValue
local canSprint = character:WaitForChild("CanSprint") :: BoolValue

local sprintSpeedModification = 0 -- how much speed has sprinting added to our movement

-- prepare FOV modifier for sprinting
local modifierInstance = Instance.new("NumberValue")
modifierInstance.Name = "SprintFOVAdd"
modifierInstance.Value = 0
modifierInstance.Parent = player:WaitForChild("PlayerScripts"):WaitForChild("FOVDaemon"):WaitForChild("Add")

player.CharacterAdded:Connect(function(_character)
	character = _character
	-- Re-grab the custom values when the player respawns
	wishDir = character:WaitForChild("WishDir") :: Vector3Value
	baseSpeed = character:WaitForChild("BaseMovementSpeed") :: NumberValue
	local isSprinting = character:WaitForChild("IsSprinting") :: BoolValue
	local canSprint = character:WaitForChild("CanSprint") :: BoolValue

	-- Reset velocities so momentum doesn't carry over between lives
	targetMoveVelocity = Vector3.zero
	moveVelocity = Vector3.zero
end)

local function getWalkDirectionWorldSpace(localDir: Vector3): Vector3
	assert(camera)
	if localDir.Magnitude <= 0 then
		return Vector3.zero
	end

	-- extract only the camera’s yaw (horizontal rotation)
	local camYaw = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	if camYaw.Magnitude > 0 then camYaw = camYaw.Unit else camYaw = Vector3.new(0, 0, -1) end

	local camRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
	if camRight.Magnitude > 0 then camRight = camRight.Unit else camRight = Vector3.new(1, 0, 0) end

	-- reconstruct world direction ignoring pitch
	local worldDir = (camRight * localDir.X + camYaw * -localDir.Z).Unit * localDir.Magnitude
	return worldDir.Unit
end

local function lerp(a: Vector3, b: Vector3, t: number): Vector3
	return a + (b - a) * t
end

local function updateMovement(delta: number)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local baseSpeed = baseSpeed.Value	
	local appliedSpeed = baseSpeed
	
	local moveDir = getWalkDirectionWorldSpace(wishDir.Value) -- note, XZ only
	local hasInput = moveDir.Magnitude > 0 -- horizontal input only

	local crouched = false

	-- vertical movement handling
	
	humanoid.HipHeight = 0
	if wishDir.Value.Y > 0 then
		--if lastTimeSinceJump + JUMP_COOLDOWN < os.clock() then
			--lastTimeSinceJump = os.clock()
			humanoid.JumpHeight = JUMP_HEIGHT
			if humanoid:GetState() == Enum.HumanoidStateType.Swimming then humanoid.JumpHeight *= 0.2 end
			humanoid.UseJumpPower = false
			humanoid.Jump = true
	end
	if wishDir.Value.Y < 0 or humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		-- crouch
		crouched = true
		-- character-resizable
		--local referenceLeftLeg = character:FindFirstChild("Left Leg") :: BasePart
		--local referenceRightLeg = character:FindFirstChild("Right Leg") :: BasePart
		--local referenceLeg : BasePart? = referenceLeftLeg or referenceRightLeg or nil
		local referenceHeightSubtraction = 2 --standard r6 leg size
		--if referenceLeg then
		--	referenceHeightSubtraction = referenceLeg.Size.Y
		--end
		humanoid.HipHeight -= referenceHeightSubtraction
	end
	
	-- application of modifiers
	
	if isSprinting.Value == true and canSprint.Value == true and not crouched and hasInput then
		-- increase sprintSpeedModification by rate until appliedSpeed = baseSpeed * SPRINT_SPEED_MODIFIER
		local targetSprintModification = math.max(0,(baseSpeed * SPRINT_SPEED_MODIFIER) - baseSpeed)
		sprintSpeedModification = math.min(targetSprintModification, sprintSpeedModification + (targetSprintModification*(SPRINT_MODIFY_APPLY_RATE * delta)))				
	elseif humanoid.FloorMaterial ~= Enum.Material.Air or humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		-- decrease sprintSpeedModification by rate until appliedSpeed = 0
		local targetSprintModification = math.max(0,(baseSpeed * SPRINT_SPEED_MODIFIER) - baseSpeed)
		sprintSpeedModification = math.max(0, sprintSpeedModification - (targetSprintModification*(SPRINT_MODIFY_DECAY_RATE * delta)))	
	end
	modifierInstance.Value = sprintSpeedModification
	
	appliedSpeed += sprintSpeedModification
	if crouched and humanoid.FloorMaterial ~= Enum.Material.Air then
		appliedSpeed *= CROUCH_SPEED_MODIFIER
	end
	if humanoid.FloorMaterial == Enum.Material.Water then
		appliedSpeed *= WATER_SPEED_MODIFIER
	end

	-- Safeguard to prevent dividing by zero later if base/applied speed drops to 0
	if appliedSpeed <= 0 then appliedSpeed = 0.001 end
	
	-- Convert our 0-to-1 moveVelocity back into actual world speed (studs per second)
	local currentVel = moveVelocity * appliedSpeed
	local speed = currentVel.Magnitude

	-- Get intended direction and speed from WishDir
	-- local moveDir = getWalkDirectionWorldSpace(wishDir.Value) -- note, XZ only
	-- local hasInput = moveDir.Magnitude > 0
	local wishSpeed = moveDir.Magnitude * appliedSpeed
	local wishDirUnit = moveDir.Magnitude > 0 and moveDir.Unit or Vector3.zero

	-- 1. Apply Friction
	if speed > 0 then
		if humanoid.FloorMaterial ~= Enum.Material.Air then
			local frictionValue = FRICTION
			if humanoid.FloorMaterial == Enum.Material.Ice then frictionValue *= 0.15 end

			local control = speed
			-- Apply STOP_SPEED penalty only when the player lets go of horizontal controls
			if not hasInput and speed < STOP_SPEED then
				control = STOP_SPEED
			end

			local drop = control * frictionValue * delta
			local newSpeed = math.max(speed - drop, 0)

			currentVel = currentVel * (newSpeed / speed)
		elseif humanoid:GetState() == Enum.HumanoidStateType.Swimming then
			local frictionValue = WATER_FRICTION
			local drop = speed * frictionValue * delta
			local newSpeed = math.max(speed - drop, 0)

			currentVel = currentVel * (newSpeed / speed)
		end
	end

	-- 2. Apply Acceleration
	if hasInput then
		local currentSpeedInWishDir = currentVel:Dot(wishDirUnit)
		local addSpeed = wishSpeed - currentSpeedInWishDir
		local accelValue = ACCELERATION
		if humanoid.FloorMaterial == Enum.Material.Air then accelValue = AIR_ACCELERATION end
		if humanoid.FloorMaterial == Enum.Material.Ice then accelValue *= 0.2 end

		if addSpeed > 0 then
			local accelSpeed = accelValue * delta * wishSpeed
			-- Cap acceleration so we don't overshoot baseSpeed
			if accelSpeed > addSpeed then
				accelSpeed = addSpeed
			end
			currentVel += (wishDirUnit * accelSpeed)
		end
	end

	-- 3. Convert back to the 0-to-1 scale and feed it to the Humanoid
	moveVelocity = currentVel / appliedSpeed

	humanoid.WalkSpeed = appliedSpeed
	if 
		--[[humanoid.FloorMaterial == Enum.Material.Water]]
		humanoid:GetState() == Enum.HumanoidStateType.Swimming	
	then
		humanoid:Move(moveVelocity + Vector3.new(0, wishDir.Value.Y, 0))
	else
		humanoid:Move(moveVelocity)
	end
end

RunS.RenderStepped:Connect(updateMovement)
