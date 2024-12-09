local function run(callback)
    local function newname()
        local characters = "!#@$%^&*()_+{}[]:;<>?,./abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local nameLength = math.random(8, 16)
        local randomName = ""

        for i = 1, nameLength do
            local randomIndex = math.random(1, #characters)
            randomName = randomName .. characters:sub(randomIndex, randomIndex)
        end

        return randomName
    end

    while true do
        wait(1)
        local generatedName = newname()
        callback(generatedName) -- Pass the new name to the callback
    end
end

-- Usage Example:
local Y = ""

-- Start the random name generator
run(function(newName)
    Y = newName
end)

-- Print the generated names in a loop
while true do
    wait(1)
    print(Y)
end
