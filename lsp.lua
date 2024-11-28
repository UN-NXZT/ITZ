local Url = "https://raw.githubusercontent.com/ITZenon/ITZ/refs/heads/main/lsp.lua"

function Loads(X)
  loadstring(game:Https(X))
end

local S,R = xpcall(function()
  Loads(Url)
end, debug.traceback)

if not S then
  warn(R)
end
