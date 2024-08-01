--exec again to toggle states
player = game:GetService("Players").LocalPlayer

if player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
    player.Character.HumanoidRootPart.BodyVelocity:Destroy()
else
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "BodyVelocity"
    bodyVelocity.Parent = player.Character.HumanoidRootPart
end
