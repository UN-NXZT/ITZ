local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local SETTINGS = {
    Distance = 100 -- Default distance for non-PC devices
}

local frozenParts = {}
local Forces = {}
local raycastDistance = SETTINGS.Distance -- Adjustable ray distance

-- Create a small sphere dynamically
local sphere = Instance.new("Part")
sphere.Shape = Enum.PartType.Ball
sphere.Size = Vector3.new(0.5, 0.5, 0.5) -- Small sphere
sphere.Anchored = true
sphere.CanCollide = false
sphere.Material = Enum.Material.Neon
sphere.BrickColor = BrickColor.new("Bright red")
sphere.Parent = workspace

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
    local rayDirection = ray.Direction * raycastDistance -- Dynamic ray distance
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

-- Adjust ray distance using scroll wheel (for PC users)
local function adjustDistance(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        raycastDistance = math.clamp(raycastDistance + input.Position.Z * 5, 10, 1000)
    end
end

-- Connect the sphere updater and input listener
local localPlayer = Players.LocalPlayer
RunService.RenderStepped:Connect(function()
    updateSphere(localPlayer)
end)

UserInputService.InputChanged:Connect(function(input)
    if UserInputService.MouseEnabled then -- Only allow scroll wheel adjustment on PC
        adjustDistance(input)
    end
end)
