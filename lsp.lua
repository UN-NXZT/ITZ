local Url = "https://raw.githubusercontent.com/ITZenon/ITZ/refs/heads/main/lsp.lua"

function Loads(X)
  loadstring(game:HttpGet(X))
end

local S,R = xpcall(function()
  Loads(Url)
end, debug.traceback)

if not S then
  warn(R)
end
