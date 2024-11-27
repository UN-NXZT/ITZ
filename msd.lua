local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local delay = 1 -- Delay in seconds
local raycastdistance = 100 -- Raycast distance
local ignore_unanchor_raycast = true -- Set to true to ignore unanchored parts in raycast, false to include them
local smooth = true -- Set to true to use tweens for smooth movement, false for direct movement
local response_time = 1 -- Time for tween in seconds (response time)

-- Create the tool
local tool = Instance.new("Tool")
tool.Name = "BringTool"
tool.RequiresHandle = false -- No need for a physical handle
tool.Parent = nil -- Start unparented until assigned to the Backpack

local sphere = Instance.new("Part")
sphere.Shape = Enum.PartType.Ball
sphere.Size = Vector3.new(0.5, 0.5, 0.5) -- Small sphere
sphere.Anchored = true
sphere.CanCollide = false
sphere.Material = Enum.Material.Neon
sphere.BrickColor = BrickColor.new("Bright red")
sphere.Parent = workspace
sphere.Transparency = 1 -- Hidden until the tool is activated

local frozenParts = {}
local Forces = {}

local isActive = false -- To track if the tool is active

-- Function to check if a part is valid for teleportation
local function CheckPart(part, localPlayer)
    return part:IsA("BasePart") 
        and not part.Anchored 
        and not part:IsDescendantOf(localPlayer.Character) 
        and part.Name ~= "Sphere"
end

-- Function to teleport unanchored parts to the sphere
local function teleportPartsToSphere(localPlayer)
    local distanceThreshold = 50 -- Adjust this threshold for performance
    for _, part in pairs(workspace:GetDescendants()) do
        if CheckPart(part, localPlayer) and (part.Position - sphere.Position).Magnitude < distanceThreshold then
            -- Destroy any existing forces on the part
            for _, c in pairs(part:GetChildren()) do
                if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
                    c:Destroy()
                end
            end

            -- Apply a force to move the part to the sphere
            local forceInstance = Instance.new("BodyPosition")
            forceInstance.Parent = part
            forceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            forceInstance.Position = sphere.Position
            table.insert(Forces, forceInstance)

            -- Track frozen parts to avoid duplicates
            if not table.find(frozenParts, part) then
                table.insert(frozenParts, part)
            end
        end
    end
end

-- Function to release all forces
local function releaseForces()
    for _, force in pairs(Forces) do
        force:Destroy()
    end
    table.clear(frozenParts)
    table.clear(Forces)
end

-- Tween the sphere's movement to the new position
local function tweenSpherePosition(newPosition)
    if smooth then
        -- Create a tween for smooth movement
        local tweenInfo = TweenInfo.new(response_time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local goal = {Position = newPosition}
        local tween = TweenService:Create(sphere, tweenInfo, goal)
        tween:Play()
    else
        -- Directly set the position if no smooth movement is required
        sphere.Position = newPosition
    end
end

-- Update sphere position based on raycast
local function updateSphere(localPlayer)
    local mousePosition = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)

    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * raycastdistance -- Use the raycastdistance
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {sphere, localPlayer.Character, workspace.CurrentCamera} -- Ignore sphere, player character, and camera
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    -- If ignore_unanchor_raycast is true, we add unanchored parts to the blacklist (so they're ignored by the raycast)
    if ignore_unanchor_raycast then
        local unanchoredParts = {}
        -- Collect all unanchored parts in the workspace
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                table.insert(unanchoredParts, part)
            end
        end
        -- Add unanchored parts to the filter
        table.insert(raycastParams.FilterDescendantsInstances, unanchoredParts)
    end

    -- Cast the ray and check if it hits any part
    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    local newPosition
    if result then
        newPosition = result.Position
    else
        newPosition = rayOrigin + rayDirection
    end

    -- Tween the sphere to the new position
    tweenSpherePosition(newPosition)

    -- Teleport parts to the sphere's position
    teleportPartsToSphere(localPlayer)
end

-- Tool Activation Logic
tool.Activated:Connect(function()
    local localPlayer = Players.LocalPlayer
    isActive = not isActive -- Toggle the active state

    if isActive then
        sphere.Transparency = 0 -- Make the sphere visible

        -- Start the loop when activated
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isActive or not tool.Parent then -- Stop loop if not active or tool is unequipped
                connection:Disconnect()
                sphere.Transparency = 1 -- Hide the sphere
                releaseForces()
                return
            end
            updateSphere(localPlayer)
            wait(delay) -- Wait for the defined delay before updating again
        end)
    else
        -- If deactivated, hide the sphere and clear forces immediately
        sphere.Transparency = 1
        releaseForces()
    end
end)

-- Cleanup when the tool is deactivated or unequipped
tool.Unequipped:Connect(function()
    sphere.Transparency = 1 -- Hide the sphere
    releaseForces()
end)

-- Add the tool to the Backpack when the game starts
local localPlayer = Players.LocalPlayer
localPlayer.CharacterAdded:Connect(function()
    if not localPlayer:FindFirstChild("Backpack") then
        localPlayer:WaitForChild("Backpack")
    end
    tool.Parent = localPlayer.Backpack
end)
