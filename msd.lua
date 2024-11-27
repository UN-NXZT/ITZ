local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration

-- Create the tool
local tool = Instance.new("Tool")
tool.Name = "TeleportTool"
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
    for _, part in pairs(workspace:GetDescendants()) do
        if CheckPart(part, localPlayer) then
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

-- Update sphere position based on raycast
local function updateSphere(localPlayer)
    local mousePosition = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)

    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {sphere, localPlayer.Character} -- Ignore sphere and player character
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if result then
        sphere.Position = result.Position
    else
        sphere.Position = rayOrigin + rayDirection
    end

    -- Continuously teleport parts to the sphere's position
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
