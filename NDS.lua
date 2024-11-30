local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

local win = lib:Window("Xyber Hub - Natural Disaster", Color3.fromRGB(44, 120, 224), Enum.KeyCode.LeftControl)

local tab = win:Tab("Main")

tab:Label("This script is in beta some function may not work.")
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

-- Change UI Color
local changeclr = win:Tab("Change UI Color")

changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    -- Apply the color to the UI
    lib:ChangePresetColor(t)  -- Ensure UI color changes correctly
end)
tab:Line()
tab:Button("Test Button", function()
    lib:Notification("Button Clicked", "You clicked the test button.")
end)

