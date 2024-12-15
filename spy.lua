local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Discord Webhook URL (replace with your own)
local webhookUrl = "YOUR_DISCORD_WEBHOOK_URL"  -- Replace with your Discord webhook URL

-- Function to make an HTTP request to fetch user information globally
local function makeRequest(url, method, body)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = method,
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = body and HttpService:JSONEncode(body) or nil
        })
    end)

    if success and response.Success then
        return HttpService:JSONDecode(response.Body)
    else
        warn("HTTP Request Failed:", response and response.StatusMessage or "Unknown error")
    end
    return nil
end

-- Function to get player information globally
local function getPlayerInfo(userId)
    local url = "https://users.roblox.com/v1/users/" .. userId
    return makeRequest(url, "GET")
end

-- Function to get the target player’s current game (via Presence API)
local function getPlayerPresence(userId)
    local url = "https://presence.roblox.com/v1/presence/users"
    local response = makeRequest(url, "POST", { userIds = { tostring(userId) } })
    if response and response.userPresences and #response.userPresences > 0 then
        local presence = response.userPresences[1]
        return presence
    end
    return nil
end

-- Function to get player friends globally
local function getPlayerFriends(userId)
    local url = "https://friends.roblox.com/v1/users/" .. userId .. "/friends"
    return makeRequest(url, "GET")
end

-- Function to fetch player thumbnail (headshot)
local function getPlayerThumbnail(userId)
    local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=150x150&format=Png"
    local response = makeRequest(url, "GET")
    if response and response.data and #response.data > 0 then
        return response.data[1].imageUrl
    end
    return nil
end

-- Function to fetch game thumbnail
local function getGameThumbnail(gameId)
    local url = "https://thumbnails.roblox.com/v1/games/icons?universeIds=" .. gameId .. "&size=512x512&format=Png"
    local response = makeRequest(url, "GET")
    if response and response.data and #response.data > 0 then
        return response.data[1].imageUrl
    end
    return nil
end

-- Function to send data to Discord webhook
local function sendToDiscord(playerInfo, playerFriendsData, gameInfo)
    local embed = {
        title = "Player Info and Game Details",
        description = "Player and their friends' information gathered from the server.",
        color = 5814783,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- Timestamp in ISO 8601 format
        fields = {}
    }

    -- Add player info
    table.insert(embed.fields, {
        name = "Player Information",
        value = string.format("**Name**: %s\n**Display Name**: %s\n**Description**: %s\n**Friends Count**: %d\n**Game**: [Game Link](https://www.roblox.com/games/%s)\n**Place**: %s",
        playerInfo.Name, playerInfo.DisplayName, playerInfo.Description, playerInfo.FriendCount,
        gameInfo.gameId, gameInfo.placeId)
    })

    -- Add player thumbnail
    local playerThumbnail = getPlayerThumbnail(playerInfo.userId)
    if playerThumbnail then
        table.insert(embed.fields, {
            name = "Player Thumbnail",
            value = string.format("![Player Thumbnail](%s)", playerThumbnail)
        })
    end

    -- Add game thumbnail
    if gameInfo.gameId then
        local gameThumbnail = getGameThumbnail(gameInfo.gameId)
        if gameThumbnail then
            table.insert(embed.fields, {
                name = "Game Thumbnail",
                value = string.format("![Game Thumbnail](%s)", gameThumbnail)
            })
        end
    end

    -- Add friends info
    if next(playerFriendsData) then
        local friendsList = ""
        for _, friend in pairs(playerFriendsData) do
            friendsList = friendsList .. string.format("**Friend**: %s (%d)\nDescription: %s\n\n", friend.FriendName, friend.FriendUserId, friend.FriendDescription)
        end
        table.insert(embed.fields, {
            name = "Friends of Player",
            value = friendsList
        })
    end

    -- Send the payload to Discord
    local payload = {
        username = "Roblox Info Bot",
        embeds = { embed }
    }

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not success then
        warn("Failed to send data to Discord:", response)
    end
end

-- Function to gather information for all players in the server and send it to Discord
local function gatherServerInfoAndSend()
    for _, player in ipairs(Players:GetPlayers()) do
        local playerId = player.UserId
        local playerInfo = getPlayerInfo(playerId) -- Global player info
        local friends = getPlayerFriends(playerId) -- Global friends list
        local presence = getPlayerPresence(playerId) -- Player presence info
        
        -- Collect player data
        local playerData = {
            Name = player.Name,
            DisplayName = player.DisplayName,
            Description = playerInfo and playerInfo.description or "No description",
            FriendCount = #friends.data,
            userId = playerId
        }

        -- Collect friends data
        local playerFriendsData = {}
        if friends and friends.data then
            for _, friend in ipairs(friends.data) do
                local friendInfo = getPlayerInfo(friend.id)
                playerFriendsData[friend.id] = {
                    FriendName = friend.name,
                    FriendUserId = friend.id,
                    FriendDescription = friendInfo and friendInfo.description or "No description"
                }
            end
        end
        
        -- Collect game info
        local gameInfo = {
            gameId = presence and presence.gameId or nil,
            placeId = presence and presence.placeId or "N/A"
        }

        -- Send all data to Discord webhook
        sendToDiscord(playerData, playerFriendsData, gameInfo)
    end
end

-- Execute the function to gather data and send it to Discord
gatherServerInfoAndSend()
