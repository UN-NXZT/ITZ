local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer

-- Sound Effects
local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Play initial sound
playSound("2865227271")

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(205, 170, 125)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Super Ring Parts v3"
Title.TextColor3 = Color3.fromRGB(101, 67, 33)
Title.BackgroundColor3 = Color3.fromRGB(222, 184, 135)
Title.Font = Enum.Font.Fondamento
Title.TextSize = 22
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = Title

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.Text = "Ring Parts Off"
ToggleButton.BackgroundColor3 = Color3.fromRGB(160, 82, 45)
ToggleButton.TextColor3 = Color3.fromRGB(255, 248, 220)
ToggleButton.Font = Enum.Font.Fondamento
ToggleButton.TextSize = 18
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

-- Decrease Radius Button
local DecreaseRadius = Instance.new("TextButton")
DecreaseRadius.Size = UDim2.new(0.2, 0, 0, 35)
DecreaseRadius.Position = UDim2.new(0.1, 0, 0.6, 0)
DecreaseRadius.Text = "<"
DecreaseRadius.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
DecreaseRadius.TextColor3 = Color3.fromRGB(255, 248, 220)
DecreaseRadius.Font = Enum.Font.Fondamento
DecreaseRadius.TextSize = 18
DecreaseRadius.Parent = MainFrame

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 10)
DecreaseCorner.Parent = DecreaseRadius

-- Increase Radius Button
local IncreaseRadius = Instance.new("TextButton")
IncreaseRadius.Size = UDim2.new(0.2, 0, 0, 35)
IncreaseRadius.Position = UDim2.new(0.7, 0, 0.6, 0)
IncreaseRadius.Text = ">"
IncreaseRadius.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
IncreaseRadius.TextColor3 = Color3.fromRGB(255, 248, 220)
IncreaseRadius.Font = Enum.Font.Fondamento
IncreaseRadius.TextSize = 18
IncreaseRadius.Parent = MainFrame

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 10)
IncreaseCorner.Parent = IncreaseRadius

-- Radius Display
local RadiusDisplay = Instance.new("TextLabel")
RadiusDisplay.Size = UDim2.new(0.4, 0, 0, 35)
RadiusDisplay.Position = UDim2.new(0.3, 0, 0.6, 0)
RadiusDisplay.Text = "Radius: 50"
RadiusDisplay.BackgroundColor3 = Color3.fromRGB(210, 180, 140)
RadiusDisplay.TextColor3 = Color3.fromRGB(101, 67, 33)
RadiusDisplay.Font = Enum.Font.Fondamento
RadiusDisplay.TextSize = 18
RadiusDisplay.Parent = MainFrame

local RadiusCorner = Instance.new("UICorner")
RadiusCorner.CornerRadius = UDim.new(0, 10)
RadiusCorner.Parent = RadiusDisplay

-- Watermark Label
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 20)
Watermark.Position = UDim2.new(0, 0, 1, -20)
Watermark.Text = "Super Ring [V3] - Cracked By Projeto LKB"
Watermark.TextColor3 = Color3.fromRGB(101, 67, 33)
Watermark.BackgroundTransparency = 1
Watermark.Font = Enum.Font.Fondamento
Watermark.TextSize = 14
Watermark.Parent = MainFrame

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 248, 220)
MinimizeButton.Font = Enum.Font.Fondamento
MinimizeButton.TextSize = 18
MinimizeButton.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 15)
MinimizeCorner.Parent = MinimizeButton

-- Minimize Functionality
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 40), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "+"
        ToggleButton.Visible = false
        DecreaseRadius.Visible = false
        IncreaseRadius.Visible = false
        RadiusDisplay.Visible = false
        Watermark.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 190), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "-"
        ToggleButton.Visible = true
        DecreaseRadius.Visible = true
        IncreaseRadius.Visible = true
        RadiusDisplay.Visible = true
        Watermark.Visible = true
    end
    playSound("12221967")
end)

-- Make GUI Draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Ring Parts Logic
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }
    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

-- Chat and Debugging
TextChatService.OnIncomingMessage = function(message)
    print("Incoming message: " .. message.Text)
end

StarterGui:SetCore("ChatMakeSystemMessage", {
    Text = "Script Loaded Successfully!",
    Color = Color3.fromRGB(0, 255, 0),
    Font = Enum.Font.Fondamento,
    TextSize = 18
})
