
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local X = Material.Load({
	Title = "Xyber Hub - Natural Disaster",
	Style = 3,
	SizeX = 500,
	SizeY = 350,
	Theme = "Dark",
	ColorOverrides = {
		MainFrame = Color3.fromRGB(235,235,235)
	}
})

local Main = X.New({
	Title = "Main"
})

local Troll = X.New({
	Title = "Troll"
})
