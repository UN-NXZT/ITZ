local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

local win = lib:Window("Xyber Hub - Natural Disaster", Color3.fromRGB(44, 120, 224), Enum.KeyCode.LeftControl)

local tab = win:Tab("Main")
local tab_ = win:Tab("Troll")

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
tab:Slider("Velocity", 0, 100, 0, function(t)
    local chr = game:GetService("Players").LocalPlayer.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    local connection

    if t > 0 and chr and hum and hum.Parent then
        connection = game:GetService("RunService").Heartbeat:Connect(function(delta)
            if hum.MoveDirection.Magnitude > 0 then
                chr:TranslateBy(hum.MoveDirection * t * delta * 10)
            end
        end)
    else
        if connection then
            connection:Disconnect()
            connection = nil
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
tab:Button("Test Button", function()
    lib:Notification("Button Clicked", "You clicked the test button.")
end)

-- Troll Section: Adding Only Fling Toggle
tab_:Toggle("Fling", false, function(t)
    if t then
        -- Start Flinging the player
        flingPlayer()
    else
        -- Stop Flinging the player
        unflingPlayer()
    end
end)

-- Fling Player Function
function flingPlayer()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    flinging = true
    -- Ensure no-clip mode to prevent clipping to the floor
    setNoClip(true)

    for _, child in pairs(character:GetDescendants()) do
        if child:IsA("BasePart") then
            child.CustomPhysicalProperties = PhysicalProperties.new(math.huge, 0.3, 0.5)  -- Make parts more flingable
        end
    end
    
    wait(.1)
    local bambam = Instance.new("BodyAngularVelocity")
    bambam.Name = randomString()
    bambam.Parent = character.HumanoidRootPart
    bambam.AngularVelocity = Vector3.new(0,99999,0)
    bambam.MaxTorque = Vector3.new(0, math.huge, 0)
    bambam.P = math.huge
    
    -- Prevent floor clipping by making sure root part is properly handled
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)  -- Lift the character above the floor
    end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Massless = true
            part.Velocity = Vector3.new(0, 0, 0)
        end
    end

    local function flingDiedF()
        unflingPlayer()
    end
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    if humanoid then
        flingDied = humanoid.Died:Connect(flingDiedF)
    end
    
    repeat
        bambam.AngularVelocity = Vector3.new(0,99999,0)
        wait(.2)
        bambam.AngularVelocity = Vector3.new(0,0,0)
        wait(.1)
    until not flinging
end

-- Unfling Player Function
function unflingPlayer()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end

    setNoClip(false)  -- Disable no-clip mode
    if flingDied then
        flingDied:Disconnect()
    end
    flinging = false

    wait(.1)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        for _, part in pairs(humanoidRootPart:GetChildren()) do
            if part:IsA("BodyAngularVelocity") then
                part:Destroy()
            end
        end
    end

    for _, child in pairs(character:GetDescendants()) do
        if child:IsA("Part") or child:IsA("MeshPart") then
            child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)  -- Reset physical properties
        end
    end
end

-- Helper to set NoClip
function setNoClip(enabled)
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = enabled  -- Prevent platform collisions
    end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled  -- Toggle collisions
        end
    end
end

-- Helper function for random string (used in BodyAngularVelocity)
function randomString()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = 10
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. charset:sub(rand, rand)
    end
    return result
end
