local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/Notifications/NotificationLIB/Module.lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/Notifications/NotificationLIB/Client.lua"))()

Notification:Notify(
    {Title = "Script Credits", Description = "This script was made by Blissful#4992! [https://github.com/Blissful4992] "},
    {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 5, Type = "option"},
    {Image = "http://www.roblox.com/asset/?id=18684458505", ImageColor = Color3.fromRGB(255, 84, 84), Callback = function(State) print(tostring(State)) end}
)
