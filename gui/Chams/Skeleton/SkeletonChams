local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/Skeleton/CodeScaffolding.lua"))()

local Skeletons = {}
for _, Player in next, game.Players:GetChildren() do
	table.insert(Skeletons, Library:NewSkeleton(Player, true));
end
game.Players.PlayerAdded:Connect(function(Player)
	table.insert(Skeletons, Library:NewSkeleton(Player, true));
end)
