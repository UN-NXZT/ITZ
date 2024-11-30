local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

local win = lib:Window("Xyber Hub - Natural Disaster", Color3.fromRGB(44, 120, 224), Enum.KeyCode.LeftControl)

local tab = win:Tab("Main")
local tab_ = win:Tab("Teleport")
local _tab = win:Tab("Misc")

tab:Label("This script is in beta, some functions may not work.")

-- Anti-Fling Toggle
local antifling
tab:Toggle("Anti-Fling", false, function(t)
    if t then
        -- Enable Anti-Fling
        antifling = game:GetService("RunService").Stepped:Connect(function()
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game:GetService("Players").LocalPlayer and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        -- Disable Anti-Fling
        if antifling then
            antifling:Disconnect()
            antifling = nil
        end
    end
end)

-- Player Speed Slider
tab:Slider("Walkspeed", 0, 500, 16, function(t)
    local character = game:GetService("Players").LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = t
        end
    end
end)

-- Player Velocity Slider
local velocityConnection -- Variable to store the Heartbeat connection

tab:Slider("Velocity", 0, 10, 0, function(t)
    -- Disconnect existing connection if it exists
    if velocityConnection then
        velocityConnection:Disconnect()
        velocityConnection = nil
    end

    -- If `t` is greater than 0, establish a new connection
    if t > 0 then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

        if humanoid then
            velocityConnection = game:GetService("RunService").Heartbeat:Connect(function(delta)
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    character:TranslateBy(moveDirection * t * delta * 10)
                end
            end)
        end
    end
end)

-- No Ads Toggle
local noAdsEnabled = false
tab:Toggle("No Ads", false, function(t)
    noAdsEnabled = t
    if noAdsEnabled then
        -- Start removing ads when enabled
        startRemovingAds()
    else
        -- Stop ad removal if disabled
        stopRemovingAds()
    end
end)

-- Change UI Color
local changeclr = win:Tab("Change UI Color")

changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    -- Apply the color to the UI
    lib:ChangePresetColor(t)  -- Ensure UI color changes correctly
end)

-- Gravity Slider
tab:Slider("Gravity", 0, 196.2, 196.2, function(t)
    -- Set the global gravity for the game
    game:GetService("Workspace").Gravity = t
end)

-- Ad Blocker Functionality
local adRemovalConnection
function startRemovingAds()
    adRemovalConnection = game:GetService("RunService").Heartbeat:Connect(function()
        pcall(function()
            for i, v in pairs(workspace:GetDescendants()) do
                if v:IsA("PackageLink") then
                    if v.Parent:FindFirstChild("ADpart") then
                        v.Parent:Destroy()
                    end
                    if v.Parent:FindFirstChild("AdGuiAdornee") then
                        v.Parent.Parent:Destroy()
                    end
                end
            end
        end)
    end)
end

function stopRemovingAds()
    if adRemovalConnection then
        adRemovalConnection:Disconnect()
        adRemovalConnection = nil
    end
end

-- Test Button
tab_:Button("TP Tool", function()
    local Tele = Instance.new("Tool")
    Tele.RequiresHandle = false
    Tele.Name = "TPTool"
    Tele.ToolTip = "Teleport Tool"
    Tele.Parent = game.Players.LocalPlayer.Backpack

    local mouseConnection -- Variable to store the connection

    Tele.Equipped:Connect(function()
        local Mouse = game.Players.LocalPlayer:GetMouse()
        mouseConnection = Mouse.Button1Down:Connect(function()
            if Mouse.Target then
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 5, 0))
                end
            end
        end)
    end)

    Tele.Unequipped:Connect(function()
        -- Disconnect the connection when the tool is unequipped
        if mouseConnection then
            mouseConnection:Disconnect()
            mouseConnection = nil
        end
    end)
end)

tab_:Button("To Lobby", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(Vector3.new(-245, 194, 307)) 
    end
end)

tab_:Button("To Map", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(Vector3.new(-136, 47, 2)) 
    end
end)



_tab:Button("Infinite Yield", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)
