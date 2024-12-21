local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

-- Create the Fluent UI window
local Window = Fluent:CreateWindow({
    Title = "DX HUB",
    SubTitle = "by uxnzxt#0000",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "main" }),
    Limited = Window:AddTab({ Title = "Limited", Icon = "gift" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Initialize options for Fluent UI
local Options = Fluent.Options

-- Add toggle to Limited Gift tab
local LimitedGiftToggle = Tabs.Limited:AddToggle("IcedCandy Auto Farm", {
    Title = "Enable Limited AutoFarm",
    Default = true,
    Callback = function(enabled)
        _G.keepdoing = enabled
    end
})

-- Add Save Manager
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("DX/CTBN")
SaveManager:BuildConfigSection(Tabs.Settings)

-- Link the toggle to Save Manager
SaveManager:LoadAutoloadConfig()
SaveManager:IgnoreThemeSettings()
SaveManager:BindToOption(LimitedGiftToggle, "LimitedGiftToggle")

-- Notification for the UI load
Fluent:Notify({
    Title = "Fluent UI Loaded",
    Content = "Proximity Handler is ready.",
    Duration = 5
})

-- Processing proximity prompts
_G.keepdoing = true
local performance = true

local function processProximityPrompts()
    local found = {}
    for _, prompt in pairs(workspace.BreakableIces:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            table.insert(found, { Prompt = prompt, Position = prompt.Parent.Position })
        end
    end
    if _G.keepdoing == false then return end
    for _, data in pairs(found) do
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = character.HumanoidRootPart
            humanoidRootPart.CFrame = CFrame.new(data.Position)
            wait(performance and 0.1 or 0.2) -- Adjust wait time based on performance mode
            fireproximityprompt(data.Prompt)
            fireproximityprompt(data.Prompt)
            fireproximityprompt(data.Prompt)
        else
            warn("Character or HumanoidRootPart not found.")
        end
    end
end

-- Searching for the pad
local function searchForPad()
    local player = game:GetService("Players").LocalPlayer
    if player.IcedCandy.Value == 10 then
        for _, model in pairs(workspace:GetChildren()) do
            local pad = model:FindFirstChild("Pad")
            if pad then
                local attachment = pad:FindFirstChild("Attachment")
                if attachment then
                    local proximityPrompt = attachment:FindFirstChild("ProximityPrompt")
                    if proximityPrompt then
                        player.Character.HumanoidRootPart.CFrame = pad.CFrame
                        fireproximityprompt(proximityPrompt)
                        fireproximityprompt(proximityPrompt)
                        fireproximityprompt(proximityPrompt)
                        break
                    end
                end
            end
        end
    end
end

-- Connect RenderStepped event for continuous pad search
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.keepdoing == true then
        searchForPad()
    end
end)

-- Main loop to process proximity prompts
while _G.keepdoing == true do
    processProximityPrompts()
end
