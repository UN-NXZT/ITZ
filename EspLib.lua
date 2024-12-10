local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Esp Libary",
    SubTitle = "By Athex",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" })
}

local ESPSettings = {
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
        blacktracer = NewLine(ESPSettings.Tracer_Thickness * 2, black),
        tracer = NewLine(ESPSettings.Tracer_Thickness, ESPSettings.Tracer_Color),
        black = NewQuad(ESPSettings.Box_Thickness * 2, black),
        box = NewQuad(ESPSettings.Box_Thickness, ESPSettings.Box_Color),
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

                        if ESPSettings.Tracers then
                            if ESPSettings.Tracer_Origin == "Middle" then
                                library.tracer.From = camera.ViewportSize * 0.5
                                library.blacktracer.From = camera.ViewportSize * 0.5
                            elseif ESPSettings.Tracer_Origin == "Bottom" then
                                library.tracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y)
                                library.blacktracer.From = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y)
                            end
                            if ESPSettings.Tracer_FollowMouse then
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
                            Colorize(ESPSettings.Box_Color)
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

-- ESP Settings UI
Tabs.ESP:AddButton({
    Title = "Toggle ESP",
    Description = "Enable or disable the ESP",
    Callback = function()
        if next(activePlayers) then
            for plr in pairs(activePlayers) do
                activePlayers[plr] = nil
                Visibility(false, {library.box, library.tracer, library.blacktracer, library.healthbar, library.greenhealth})
            end
        else
            for _, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v.Name ~= player.Name then
                    ESP(v)
                end
            end
        end
    end
})

Tabs.ESP:AddColorpicker("BoxColor", {
    Title = "Box Color",
    Default = ESPSettings.Box_Color,
    Callback = function(Color)
        ESPSettings.Box_Color = Color
        for _, library in pairs(activePlayers) do
            library.box.Color = Color
        end
    end
})

Tabs.ESP:AddColorpicker("TracerColor", {
    Title = "Tracer Color",
    Default = ESPSettings.Tracer_Color,
    Callback = function(Color)
        ESPSettings.Tracer_Color = Color
        for _, library in pairs(activePlayers) do
            library.tracer.Color = Color
            library.blacktracer.Color = Color
        end
    end
})

Tabs.ESP:AddSlider("BoxThickness", {
    Title = "Box Thickness",
    Min = 1,
    Max = 5,
    Default = ESPSettings.Box_Thickness,
    Callback = function(Value)
        ESPSettings.Box_Thickness = Value
    end
})

Tabs.ESP:AddSlider("TracerThickness", {
    Title = "Tracer Thickness",
    Min = 1,
    Max = 5,
    Default = ESPSettings.Tracer_Thickness,
    Callback = function(Value)
        ESPSettings.Tracer_Thickness = Value
    end
})

Tabs.ESP:AddToggle("Tracers", {
    Title = "Enable Tracers",
    Default = ESPSettings.Tracers,
    Callback = function(Value)
        ESPSettings.Tracers = Value
    end
})

Tabs.ESP:AddDropdown("TracerOrigin", {
    Title = "Tracer Origin",
    Values = {"Middle", "Bottom"},
    Default = ESPSettings.Tracer_Origin,
    Callback = function(Value)
        ESPSettings.Tracer_Origin = Value
    end
})

Tabs.ESP:AddToggle("FollowMouse", {
    Title = "Tracer Follow Mouse",
    Default = ESPSettings.Tracer_FollowMouse,
    Callback = function(Value)
        ESPSettings.Tracer_FollowMouse = Value
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
