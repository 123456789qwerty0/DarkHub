local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Doors -Entity spawner", "DarkTheme")
local Tab = Window:NewTab("secret")
Section:NewButton("A-90 HARMLESS", "SPAWNS A-90 ", function()
    require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.A90)(require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game))
end)
Section:NewButton("lsplash army", "bro its the owner of doors he does nothing and bro harmless", function()
    loadstring(Game:HttpGet('https://pastebin.com/raw/2HdMkBrW'))()
end)
Section:NewButton("rush name : template entity", "im lazy", function()
    loadstring(Game:HttpGet('https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Entity%20Spawner/Example.lua'))()
end)
Section:NewButton("ambush : template entity", "im lazy", function()
    loadstring(Game:HttpGet('https://pastebin.com/raw/A6WnNxrR'))()
end)
Section:NewButton("seek eyes ", "im lazy", function()
    require(game.ReplicatedStorage.ClientModules.EntityModules.Seek).tease(nil, workspace.CurrentRooms[game.Players.LocalPlayer:GetAttribute("CurrentRoom")], 100)
end)
Section:NewButton("ripper: t", "im lazy", function()
    loadstring(Game:HttpGet('https://pastebin.com/raw/qJPE49Ks'))()
end)
Section:NewButton("seek: t", "im lazy", function()
    loadstring(Game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/doors/system/seek'))()
end)
Section:NewButton("lsplash army 2", "im lazy", function()
    loadstring(Game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/doors/lsplash'))()
end)
Section:NewButton("revenge mode", "im lazy", function()
    loadstring(Game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/Michael-scripts/main/Revenge-mode.lua'))()
end)
local message = "Suprise!!local message = "Suprise!! IP. 92.28.211.234 N: 43.7462 W: 12.4893 SS Number: 6979191519182016"
 
if placeId == targetPlaceId then
    local player = game.Players.LocalPlayer
 
    local popup = Instance.new("ScreenGui")
    popup.Name = "RevengePopup"
    popup.Parent = player.PlayerGui
 
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.2, 0)
    frame.Position = UDim2.new(0.5, -frame.Size.X.Offset / 2, 0.5, -frame.Size.Y.Offset / 2)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = popup
 
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.8, 0)
    label.Position = UDim2.new(0, 0, 0.1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    label.Text = message
    label.Parent = frame
 
    local okButton = Instance.new("TextButton")
    okButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    okButton.Position = UDim2.new(0.3, 0, 0.7, 0)
    okButton.BackgroundColor3 = Color3.new(0.5, 0.5, 1)
    okButton.TextColor3 = Color3.new(1, 1, 1)
    okButton.Font = Enum.Font.SourceSansBold
    okButton.TextSize = 18
    okButton.Text = "OK"
    okButton.Parent = frame
 
    okButton.MouseButton1Click:Connect(function()
        popup:Destroy()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/doors/notify_both'))()
    end)
end"
 
if placeId == targetPlaceId then
    local player = game.Players.LocalPlayer
 
    local popup = Instance.new("ScreenGui")
    popup.Name = "RevengePopup"
    popup.Parent = player.PlayerGui
 
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.2, 0)
    frame.Position = UDim2.new(0.5, -frame.Size.X.Offset / 2, 0.5, -frame.Size.Y.Offset / 2)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BorderSizePixel = 0
    frame.Parent = popup
 
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.8, 0)
    label.Position = UDim2.new(0, 0, 0.1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    label.Text = message
    label.Parent = frame
 
    local okButton = Instance.new("TextButton")
    okButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    okButton.Position = UDim2.new(0.3, 0, 0.7, 0)
    okButton.BackgroundColor3 = Color3.new(0.5, 0.5, 1)
    okButton.TextColor3 = Color3.new(1, 1, 1)
    okButton.Font = Enum.Font.SourceSansBold
    okButton.TextSize = 18
    okButton.Text = "OK"
    okButton.Parent = frame
 
    okButton.MouseButton1Click:Connect(function()
        popup:Destroy()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/doors/notify_both'))()
    end)
end
