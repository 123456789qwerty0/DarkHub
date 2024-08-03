local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local BoomboxBG = Instance.new("ImageLabel")
local TitleLabel = Instance.new("TextLabel")
local PlayButton = Instance.new("TextButton")
local IDbox = Instance.new("TextBox")

--Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.321942449, 0, 0.0989974961, 0)
Frame.Size = UDim2.new(0, 384, 0, 192)

BoomboxBG.Name = "BoomboxBG"
BoomboxBG.Parent = Frame
BoomboxBG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BoomboxBG.BorderColor3 = Color3.fromRGB(0, 0, 0)
BoomboxBG.BorderSizePixel = 0
BoomboxBG.Position = UDim2.new(0.00260416674, 0, 0.166666672, 0)
BoomboxBG.Size = UDim2.new(0, 383, 0, 160)
BoomboxBG.Image = "http://www.roblox.com/asset/?id=18784785337"

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = Frame
TitleLabel.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.BorderSizePixel = 0
TitleLabel.Size = UDim2.new(0, 384, 0, 32)
TitleLabel.Font = Enum.Font.SourceSans
TitleLabel.Text = "Private Boombox Panel"  
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 27.000

PlayButton.Name = "PlayButton"
PlayButton.Parent = Frame
PlayButton.BackgroundColor3 = Color3.fromRGB(139, 139, 139)
PlayButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
PlayButton.BorderSizePixel = 0
PlayButton.Position = UDim2.new(0.255208343, 0, 0.671875, 0)
PlayButton.Size = UDim2.new(0, 200, 0, 50)
PlayButton.Font = Enum.Font.SourceSans
PlayButton.Text = "Play!"
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.TextSize = 38.000

IDbox.Name = "IDbox"
IDbox.Parent = Frame
IDbox.BackgroundColor3 = Color3.fromRGB(139, 139, 139)
IDbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
IDbox.BorderSizePixel = 0
IDbox.Position = UDim2.new(0.236979172, 0, 0.234375, 0)
IDbox.Size = UDim2.new(0, 213, 0, 42)
IDbox.Font = Enum.Font.SourceSans
IDbox.Text = "Sound ID Goes Here"
IDbox.TextColor3 = Color3.fromRGB(255, 255, 255)
IDbox.TextSize = 23.000

-- Scripts:

local function YJDHRT_script() -- Frame.SmoothDrag 
	local script = Instance.new('LocalScript', Frame)

	-- Need help? Check me out on the devforum!
	-- Link: https://devforum.roblox.com/t/smooth-dragging-easily-drag-your-frames/2508276

	local Drag = script.Parent
	gsCoreGui = game:GetService("CoreGui")
	gsTween = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local dragging
	local dragInput
	local dragStart
	local startPos
	local function update(input)
		local delta = input.Position - dragStart
		local dragTime = 0.04
		local SmoothDrag = {}
		SmoothDrag.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		local dragSmoothFunction = gsTween:Create(Drag, TweenInfo.new(dragTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), SmoothDrag)
		dragSmoothFunction:Play()
	end
	Drag.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Drag.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	Drag.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and Drag.Size then
			update(input)
		end
	end)
end
coroutine.wrap(YJDHRT_script)()

local function playMusic()
	local soundId = "rbxassetid://" .. IDbox.Text
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = game.Workspace
	sound:Play()
end

-- PlayButton function
PlayButton.MouseButton1Click:Connect(playMusic)

-- Notifications
game.StarterGui:SetCore("SendNotification", {
	Title = "Loaded!",
	Text = "Private Boombox Panel Loaded! [made by susmic123_real]",
	Duration = 5,
})
game.StarterGui:SetCore("SendNotification", {
	Title = "Issues",
	Text = "If you find any bugs/glitches, You can report them to the github! [https://tinyurl.com/DarkHubErrors]",
	Duration = 25,
})
wait(2)
game.StarterGui:SetCore("SendNotification", {
	Title = "Information",
	Text = "This gui was based on scuba#0001's yeet gui!",
	Duration = 5,
})
