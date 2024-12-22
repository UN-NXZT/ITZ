local customDirectory = workspace

local function findProximityPrompts(parent)
    local prompts = {}
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            table.insert(prompts, descendant)
        end
    end
    return prompts
end

local promptsFound = findProximityPrompts(customDirectory)

for _, prompt in ipairs(promptsFound) do
    print("Found ProximityPrompt:", prompt:GetFullName())

    prompt.Triggered:Connect(function(player)
        print(player.Name, "triggered the ProximityPrompt:", prompt:GetFullName())
    end)
end

print("Total ProximityPrompts found:", #promptsFound)
