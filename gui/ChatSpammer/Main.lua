-- Monstrum's Gui to Lua
-- Version: 3.2

-- Instances:

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local SpamButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local SpamMessage = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local ambientShadow = Instance.new("ImageLabel")
local penumbraShadow = Instance.new("ImageLabel")
local umbraShadow = Instance.new("ImageLabel")

-- Properties:

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.340827346, 0, 0.092731826, 0)
Frame.Size = UDim2.new(0, 412, 0, 190)

SpamButton.Name = "SpamButton"
SpamButton.Parent = Frame
SpamButton.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
SpamButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
SpamButton.BorderSizePixel = 0
SpamButton.Position = UDim2.new(0.259708732, 0, 0.66315788, 0)
SpamButton.Size = UDim2.new(0, 200, 0, 50)
SpamButton.Font = Enum.Font.SourceSans
SpamButton.Text = "Spam!"
SpamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamButton.TextSize = 26.000

UICorner.Parent = SpamButton

SpamMessage.Name = "SpamMessage"
SpamMessage.Parent = Frame
SpamMessage.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
SpamMessage.BorderColor3 = Color3.fromRGB(0, 0, 0)
SpamMessage.BorderSizePixel = 0
SpamMessage.Position = UDim2.new(0.257281542, 0, 0.32631579, 0)
SpamMessage.Size = UDim2.new(0.485436887, 0, 0.263157904, 0)
SpamMessage.Font = Enum.Font.SourceSans
SpamMessage.Text = "Enter text to spam.."
SpamMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamMessage.TextSize = 26.000
SpamMessage.TextWrapped = true

UICorner_2.Parent = SpamMessage

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = Frame
TitleLabel.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.BorderSizePixel = 0
TitleLabel.Position = UDim2.new(0.0339805819, 0, 0.0631578937, 0)
TitleLabel.Size = UDim2.new(0, 200, 0, 50)
TitleLabel.Font = Enum.Font.SourceSans
TitleLabel.Text = "Chat Spammer 1.0 "
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 24.000

ambientShadow.Name = "ambientShadow"
ambientShadow.Parent = Frame
ambientShadow.AnchorPoint = Vector2.new(0.5, 0.5)
ambientShadow.BackgroundTransparency = 1.000
ambientShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
ambientShadow.Size = UDim2.new(1, 3, 1, 3)
ambientShadow.ZIndex = 0
ambientShadow.Image = "rbxassetid://1316045217"
ambientShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
ambientShadow.ImageTransparency = 0.880
ambientShadow.ScaleType = Enum.ScaleType.Slice
ambientShadow.SliceCenter = Rect.new(10, 10, 118, 118)

penumbraShadow.Name = "penumbraShadow"
penumbraShadow.Parent = Frame
penumbraShadow.AnchorPoint = Vector2.new(0.5, 0.5)
penumbraShadow.BackgroundTransparency = 1.000
penumbraShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
penumbraShadow.Size = UDim2.new(1, 3, 1, 3)
penumbraShadow.ZIndex = 0
penumbraShadow.Image = "rbxassetid://1316045217"
penumbraShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
penumbraShadow.ImageTransparency = 0.880
penumbraShadow.ScaleType = Enum.ScaleType.Slice
penumbraShadow.SliceCenter = Rect.new(10, 10, 118, 118)

umbraShadow.Name = "umbraShadow"
umbraShadow.Parent = Frame
umbraShadow.AnchorPoint = Vector2.new(0.5, 0.5)
umbraShadow.BackgroundTransparency = 1.000
umbraShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
umbraShadow.Size = UDim2.new(1, 3, 1, 3)
umbraShadow.ZIndex = 0
umbraShadow.Image = "rbxassetid://1316045217"
umbraShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
umbraShadow.ImageTransparency = 0.860
umbraShadow.ScaleType = Enum.ScaleType.Slice
umbraShadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Scripts:

local function NZGRLMG_script() -- Frame.GUIDrag 
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
coroutine.wrap(NZGRLMG_script)()

local function onSpamButtonClick()
    local A_1 = SpamMessage.Text
    local A_2 = "All"
    local Event = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
    Event:FireServer(A_1, A_2)
end

SpamButton.MouseButton1Click:Connect(onSpamButtonClick)

-- Notifications on startup
game.StarterGui:SetCore("SendNotification", {
    Title = "Loaded!",
    Text = "Chat Spammer 1.0 [made by susmic123_real]",
    Duration = 5,
})

game.StarterGui:SetCore("SendNotification", {
    Title = "Issues",
    Text = "If you find any bugs/glitches, You can report them to the github! [https://tinyurl.com/DarkHubErrors]",
    Duration = 25,
})
