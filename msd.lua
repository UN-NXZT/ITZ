local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Get the local player and their mouse
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Create a small sphere dynamically
local sphere = Instance.new("Part")
sphere.Shape = Enum.PartType.Ball
sphere.Size = Vector3.new(0.5, 0.5, 0.5) -- Small sphere
sphere.Anchored = true
sphere.CanCollide = false
sphere.Material = Enum.Material.Neon
sphere.BrickColor = BrickColor.new("Bright red")
sphere.Parent = workspace

-- Function to update the sphere's position
local function updateSphere()
    -- Create a ray from the mouse's 2D position
    local mousePosition = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)

    -- Extend the ray into the world
    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * 1000 -- Ray length
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character, sphere} -- Ignore the player and sphere
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    -- Perform the raycast
    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    -- Update sphere position if the ray hits something
    if result then
        sphere.Position = result.Position
    else
        -- Default position if nothing is hit
        sphere.Position = rayOrigin + rayDirection
    end
end

-- Continuously update the sphere's position
RunService.RenderStepped:Connect(updateSphere)
