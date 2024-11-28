local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
    -- Get the origin (camera position) and direction (mouse hit position)
    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (mouse.Hit.Position - origin).Unit * 500 -- Extend ray 500 studs

    -- Raycast parameters
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character} -- Ignore player character
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    -- Perform raycast
    local result = workspace:Raycast(origin, direction, raycastParams)

    if result then
        -- Create a red ball at the hit position
        local hitPosition = result.Position
        local redBall = Instance.new("Part")
        redBall.Shape = Enum.PartType.Ball
        redBall.Size = Vector3.new(1, 1, 1) -- Size of the ball
        redBall.Position = hitPosition
        redBall.Anchored = true
        redBall.CanCollide = false
        redBall.Material = Enum.Material.Neon
        redBall.BrickColor = BrickColor.new("Bright red")
        redBall.Parent = workspace

        -- Update raycast parameters to ignore this new red ball
        table.insert(raycastParams.FilterDescendantsInstances, redBall)

      local frozenParts = {}
      local Forces = {}

      local function CheckPart(part, localPlayer)
        return part:IsA("BasePart") 
        and not part.Anchored 
        and not part:IsDescendantOf(localPlayer.Character) 
        and part.Name ~= "Sphere"
      end

      for _, part in pairs(workspace:GetDescendants()) do
        if CheckPart(part, localPlayer) then
           for _, c in pairs(part:GetChildren()) do
            if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
              c:Destroy()
          end
        end
           local forceInstance = Instance.new("BodyPosition")
            forceInstance.Parent = part
            forceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            forceInstance.Position = sphere.Position
            table.insert(Forces, forceInstance)

          if not table.find(frozenParts, part) then
            table.insert(frozenParts, part)
          end
        end

        -- Remove the ball after 1 second
        task.delay(1, function()
            if redBall then
                redBall:Destroy()
            end
        end)
    end
end)
