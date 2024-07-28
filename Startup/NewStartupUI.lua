--discord ui
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/UiLibraries/DiscordUI/Lib.lua")()

local win = DiscordLib:Window("Darkhub")

local serv = win:Server("Startup Menu", "")

local btns = serv:Channel("main")

btns:Button("Load DarkHub", function()
DiscordLib:Notification("Notification", "Killed everyone!", "Okay!")
end)
  
local github = serv:Channel("github")
github:Button("Copy Github", function()
setclipboard("https://github.com/123456789qwerty0/DarkHub/tree/main")
end)

local lbls = serv:Channel("Supported Games")
lbls:Seperator
lbls:Label("List of supported games:")
lbls:Seperator
lbls:Label("MM2")
lbls:Label("Influencer Meeting Place")
lbls:Label("Doors")
lbls:Label("KAT")
lbls:Label("Clip It")
lbls:Label("Color Or Die")
lbls:Label("Rainbow Friends")
lbls:Label("Rainbow Friends Chapter 2")
lbls:Label("Piggy")


