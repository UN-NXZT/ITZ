--[[ Configuration ]]
local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom", -- "Middle" or "Bottom"
    Tracer_FollowMouse = false,
    Tracers = true
}
local Team_Check = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}
local TeamColor = true

--[[ Main Script ]]
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()
local activePlayers = {} -- Tracks players with active ESP

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0, 0)
    quad.PointB = Vector2.new(0, 0)
    quad.PointC = Vector2.new(0, 0)
    quad.PointD = Vector2.new(0, 0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    for _, x in pairs(lib) do
        x.Visible = state
    end
end

local black = Color3.fromRGB(0, 0, 0)

local function ESP(plr)
    if activePlayers[plr] then return end -- Prevent duplicate ESP for the same player
    activePlayers[plr] = true

    local library = {
        blacktracer = NewLine(Settings.Tracer_Thickness * 2, black),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        black = NewQuad(Settings.Box_Thickness * 2, black),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black)
    }

    local function Colorize(color)
        for _, x in pairs(library) do
            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black then
                x.Color = color
            end
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid.Health > 0 then
                    local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                    if OnScreen then
                        local DistanceY = 50 -- Adjusted size of the box
                        local function Size(item)
                            item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY)
                            item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY)
                            item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY)
                            item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY)
                        end
                        Size(library.box)
                        Size(library.black)

                        if Settings.Tracers then
                            if Settings.Tracer_Origin == "Middle" then
                                library.tracer.From = camera.ViewportSize * 0.5
                                library.blacktracer.From = camera.ViewportSize * 0.5
                            elseif Settings.Tracer_Origin == "Bottom" then
                                library.tracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y)
                                library.blacktracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y)
                            end
                            if Settings.Tracer_FollowMouse then
                                library.tracer.From = Vector2.new(mouse.X, mouse.Y + 36)
                                library.blacktracer.From = Vector2.new(mouse.X, mouse.Y + 36)
                            end
                            library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY)
                            library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY)
                        end

                        if Team_Check.TeamCheck then
                            if plr.TeamColor == player.TeamColor then
                                Colorize(Team_Check.Green)
                            else
                                Colorize(Team_Check.Red)
                            end
                        elseif TeamColor then
                            Colorize(plr.TeamColor.Color)
                        else
                            Colorize(Settings.Box_Color)
                        end

                        Visibility(true, library)
                    else
                        Visibility(false, library)
                    end
                else
                    Visibility(false, library)
                end
            else
                Visibility(false, library)
                if not game:GetService("Players"):FindFirstChild(plr.Name) then
                    connection:Disconnect()
                    activePlayers[plr] = nil -- Remove from active players
                end
            end
        end)
    end

    coroutine.wrap(Updater)()
end

for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= player.Name then
        ESP(v)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name then
        ESP(newplr)
    end
end)

-- Periodic ESP Reset
task.spawn(function()
    while task.wait(10) do
        for plr in pairs(activePlayers) do
            if not game:GetService("Players"):FindFirstChild(plr.Name) then
                activePlayers[plr] = nil
            end
        end
    end
end)

--[[ Fluent UI Setup ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Home", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ESP Toggle
local EspToggle = Tabs.Main:AddToggle("ESPEnabled", {
    Title = "Enable ESP",
    Default = true,
    Callback = function(Value)
        if Value then
            -- Enable ESP
            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                if plr.Name ~= player.Name then
                    ESP(plr)
                end
            end
        else
            -- Disable ESP
            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                if plr.Name ~= player.Name then
                    activePlayers[plr] = nil
                end
            end
        end
    end
})

-- ESP Color Customization
local BoxColorPicker = Tabs.Settings:AddColorpicker("BoxColor", {
    Title = "Box Color",
    Default = Settings.Box_Color,
    Callback = function(Color)
        Settings.Box_Color = Color
    end
})

local TracerColorPicker = Tabs.Settings:AddColorpicker("TracerColor", {
    Title = "Tracer Color",
    Default = Settings.Tracer_Color,
    Callback = function(Color)
        Settings.Tracer_Color = Color
    end
})

-- Tracer Settings
Tabs.Settings:AddDropdown("TracerOrigin", {
    Title = "Tracer Origin",
    Values = {"Middle", "Bottom"},
    Default = "Bottom",
    Callback = function(Value)
        Settings.Tracer_Origin = Value
    end
})

Tabs.Settings:AddSlider("TracerThickness", {
    Title = "Tracer Thickness",
    Min = 1,
    Max = 5,
    Default = Settings.Tracer_Thickness,
    Callback = function(Value)
        Settings.Tracer_Thickness = Value
    end
})

Tabs.Settings:AddToggle("ShowTracers", {
    Title = "Show Tracers",
    Default = Settings.Tracers,
    Callback = function(Value)
        Settings.Tracers = Value
    end
})

--soon
