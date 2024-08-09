
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")


local Midnight = {
    Connections = {},
    Flags = {},
    Tabs = {},

    NotifySound = 4590657391,
    NotifyVolume = 2,

    UISize = 220,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Opened = false,

    SaveFolder = nil,

    LocalPlayer = Players.LocalPlayer,

    Platform = Enum.Platform.None,
    Mobile = false,
    Studio = RunService:IsStudio()
}

pcall(function() Midnight.Platform = UserInputService:GetPlatform() end)
Midnight.Mobile = UserInputService:GetPlatform() == Enum.Platform.Android or UserInputService:GetPlatform() == Enum.Platform.IOS

if Midnight.Mobile then
    Midnight.UISize = 180
end


export type WindowOptions = {
    Title: string,
    Blur: boolean,
    NotifySound: number,
    NotifyVolume: number,
    SaveFolder: string,
    ToggleKeybind: Enum.KeyCode
}

export type ElementButtonOptions = {
    Name: string,
    Keybind: Enum.KeyCode | Enum.UserInputType,
    Callback: (TimesClicked: number) -> ()
}

export type ElementToggleOptions = {
    Name: string,
    Flag: string,
    Value: boolean,
    Keybind: Enum.KeyCode | Enum.UserInputType,
    Mode: "Hold" | "Toggle",
    Callback: (NewValue: boolean, OldValue: boolean) -> ()
}

export type ButtonOptions = {
    Name: string,
    DoubleClick: boolean,
    Callback: (TimesClicked: number) -> ()
}

export type ToggleOptions = {
    Name: string,
    Flag: string,
    Value: boolean,
    Callback: (NewValue: boolean, OldValue: boolean) -> ()
}

export type SliderOptions = {
    Name: string,
    Flag: string,
    Value: number,
    Increment: number,
    Min: number,
    Max: number,
    Callback: (NewValue: number, OldValue: number) -> ()
}

export type TextboxOptions = {
    Name: string,
    Flag: string,
    ResetOnFocus: boolean,
    Text: string,
    Callback: (NewText: string, OldText: string) -> ()
}

export type DropdownOptions ={
    Name: string,
    Flag: string,
    AllowNull: boolean,
    Multi: boolean,
    Values: table,
    Callback: (NewValue: table, OldValue: table) -> ()
}

export type KeyPickerOptions = {
    Name: string,
    Flag: string,
    Keybind: Enum.KeyCode | Enum.UserInputType,
    Mode: "Hold" | "Toggle",
    Callback: (NewState: boolean, OldState: boolean) -> ()
}

export type ColorPickerOptions = {
    Name: string,
    Flag: string,
    Color: Color3,
    Callback: (NewColor: Color3, OldColor: Color3) -> ()
}


local defaultToggleColor = Color3.fromRGB(60, 60, 60)
local hoveringToggleColor = Color3.fromRGB(100, 100, 100)
local enabledToggleColor = Color3.fromRGB(140, 140, 140)

local semiBoldFont = Font.fromId(12187365364, Enum.FontWeight.SemiBold)
local mediumFont = Font.fromId(12187365364, Enum.FontWeight.Medium)
local regularFont = Font.fromId(12187365364)

local keyCodesName = {
    [Enum.KeyCode.Insert] = "Ins",
    [Enum.KeyCode.Delete] = "Del",
    [Enum.KeyCode.PageDown] = "PgDn",
    [Enum.KeyCode.PageUp] = "PgUp",

    [Enum.KeyCode.LeftAlt] = "LAlt",
    [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.KeyCode.LeftControl] = "LCtrl",
    [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftShift] = "LShift",
    [Enum.KeyCode.RightShift] = "RShift",
    
    [Enum.UserInputType.MouseButton1] = "LMB",
    [Enum.UserInputType.MouseButton2] = "RMB",
    [Enum.UserInputType.MouseButton3] = "MMB",
}

local parser = {
    ElementToggle = {
        Save = function(data)
            return { Type = "ElementToggle", Value = data.Value, Keybind = tostring(data.Keybind), Mode = data.Mode }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                task.spawn(function() Midnight.Flags[flag]:Set(data.Value) end)
                Midnight.Flags[flag]:SetKeybind(GetKeybindFromString(data.Keybind))
                Midnight.Flags[flag].Mode = data.Mode
            end
        end
    },
    Toggle = {
        Save = function(data)
            return { Type = "Toggle", Value = data.Value }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                Midnight.Flags[flag]:Set(data.Value)
            end
        end
    },
    Slider = {
        Save = function(data)
            return { Type = "Slider", Value = data.Value }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                Midnight.Flags[flag]:Set(data.Value)
            end
        end
    },
    Textbox = {
        Save = function(data)
            return { Type = "Textbox", Text = data.Text }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                Midnight.Flags[flag]:Set(data.Text)
            end
        end
    },
    Dropdown = {
        Save = function(data)
            return { Type = "Dropdown", Value = data.Value }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                Midnight.Flags[flag]:SetValue(data.Value)
            end
        end
    },
    KeyPicker = {
        Save = function(data)
            return { Type = "KeyPicker", Keybind = tostring(data.Keybind), Mode = data.Mode }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                Midnight.Flags[flag]:SetKeybind(GetKeybindFromString(data.Keybind))
                Midnight.Flags[flag].Mode = data.Mode
            end
        end
    },
    ColorPicker = {
        Save = function(data)
            return { Type = "ColorPicker", Color = data.Color:ToHex() }
        end,
        Load = function(flag, data)
            if Midnight.Flags[flag] then
                Midnight.Flags[flag]:SetColor(Color3.fromHex(data.Color))
            end
        end
    }
}

local hueSequenceTable = {}
for hue = 0, 1, 0.1 do
    table.insert(hueSequenceTable, ColorSequenceKeypoint.new(hue, Color3.fromHSV(hue, 1, 1)))
end

function GetKeybindFromString(string)
    if string == "nil" then return nil end
    local keybindSplit = string.split(string, ".")

    table.remove(keybindSplit, 1)

    local keybind = Enum
    for _, v in ipairs(keybindSplit) do
        keybind = keybind[v]
    end

    return keybind
end

local function CheckSaveFolder()
    if Midnight.SaveFolder == nil then return false end

    if not isfolder(Midnight.SaveFolder) then
        makefolder(Midnight.SaveFolder)
    end

    if not isfolder(Midnight.SaveFolder .. "/configs") then
        makefolder(Midnight.SaveFolder .. "/configs")
    end

    return true
end

local function SaveConfig(name)
    if not CheckSaveFolder() then return false, "SaveFolder is nil" end
    if name:gsub(" ", "") == "" then return Midnight:Notify("Config Name can't be empty") end

    local data = {}
    for flag, value in pairs(Midnight.Flags) do
        if value.Type and parser[value.Type] then
            data[flag] = parser[value.Type].Save(value)
        end
    end

    writefile(Midnight.SaveFolder .. "/configs/" .. name .. ".json", tostring(HttpService:JSONEncode(data)))
    return true
end

local function LoadConfig(name)
    if not CheckSaveFolder() then return false, "SaveFolder is nil" end
    if name:gsub(" ", "") == "" then return Midnight:Notify("Config Name can't be empty") end

    local file = Midnight.SaveFolder .. "/configs/" .. name .. ".json"
    if not isfile(file) then 
        return false, "Invalid file"
    end

    local data = HttpService:JSONDecode(readfile(file))
    for flag, value in pairs(data) do
        if not (value.Type and parser[value.Type]) then continue end
        task.spawn(parser[value.Type].Load, flag, value)
    end

    return true
end

local function GetSavedConfigs()
    if not CheckSaveFolder() then return false, "SaveFolder is nil" end

    local path = Midnight.SaveFolder .. "/configs"
    local configsList = listfiles(path)

    local configs = {}
    for i = 1, #configsList do
        local config = configsList[i]
        if config:sub(-5) == ".json" then
            table.insert(configs, config:sub(#path + 2, -6))
        end
    end

    return configs
end


local function HasProperty(instance: Instance, property: string)
    local _ = instance[property]
end

local function Create(class: string, properties: table): Instance
    local instance = Instance.new(class)

    local borderSuccess = pcall(HasProperty, instance, "BorderSizePixel")
    if borderSuccess then
        instance["BorderSizePixel"] = 0
    end

    for property, value in pairs(properties) do
        instance[property] = value
    end

    return instance
end

local function Round(number, factor)
    local result = math.floor(number / factor + (math.sign(number) * 0.5)) * factor
    if result < 0 then result += factor end
    return result
end

local function MakeDraggable(instance: Instance, main: Instance)
    local dragging = false
    local dragInput
    local mousePos
    local framePos

    instance.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    instance.InputChanged:Connect(function(input: InputObject)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)

    Midnight:AddConnection(UserInputService.InputChanged:Connect(function(input: InputObject)
        if dragging and input == dragInput then
            local delta = input.Position - mousePos
            main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end))
end


local UI = Create("ScreenGui", {
    DisplayOrder = 0,
    Name = "Midnight",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = Midnight.Studio and Midnight.LocalPlayer.PlayerGui or CoreGui
})


local Windows = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, -12, 1, -12),
    Parent = UI
})


local Notifications = Create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -8, 1, -8),
    Size = UDim2.new(0, 480, 1, -12),
    Parent = UI
})

Create("UIListLayout", {
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 6),
    Parent = Notifications
})


local BaseComponents = {}  do
    local Components = {}

    function Components:AddDivider()
        local DividerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Parent = self.Container
        })       
        
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = DividerHolder
        })

        local Divider = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.fromScale(1, 1),
            Parent = DividerHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Divider
        })

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = Divider
        })
    end

    function Components:AddLabel(text: string)
        --// Text Label \\--
        local TextLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            Text = "",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 20,
            TextTransparency = 0.5,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            Parent = TextLabel
        })

        local Label = {
            Text = text or "No Text"
        }

        function Label:Set(newText: string)
            Label.Text = newText

            local params = Instance.new("GetTextBoundsParams")
            params.Text = Label.Text
            params.Font = regularFont
            params.Size = 20
            params.Width = Midnight.UISize - 24

            local size = TextService:GetTextBoundsAsync(params)
            
            TextLabel.Size = UDim2.new(1, 0, 0, size.Y + 7)
            TextLabel.Text = Label.Text
        end

        do
            Label:Set(Label.Text)
        end

        return Label
    end

    function Components:AddButton(options: ButtonOptions)
        --// Button Holder \\--
        local ButtonHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonHolder
        })

        --// Actual Button \\--
        local ActualButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            Parent = ButtonHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = ActualButton
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ActualButton,
        })

        local ButtonStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ActualButton
        })

        --// Locked \\--
        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072718362",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, 7, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            Visible = false,
            Parent = ButtonHolder
        })

        local LockedHover: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Visible = false,
            Parent = ButtonHolder,
        })

        --// Button Table \\--
        local Button = {
            Hovering = false,
            Locked = false,
            TimesClicked = 0,
            Clicking = false,

            Name = options.Name or "Button",
            DoubleClick = options.DoubleClick or false,

            Type = "Button"
        }

        function Button:SetClicking(clicking)
            Button.Clicking = clicking

            ActualButton.Text = Button.Clicking and "Are you sure?" or options.Name
            ActualButton.TextTransparency = Button.Clicking and 0 or (Button.Hovering and 0.25 or 0.5)
        end

        function Button:SetLocked(locked: boolean)
            Button.Locked = locked
            
            LockedHover.Visible = Button.Locked
            if Button.Hovering then
                LockedIcon.Visible = Button.Locked
            end
        end

        function Button:SetName(newName: string)
            Button.Name = newName

            if not Button.Clicking then
                ActualButton.Text = Button.Name
            end
        end

        --// Button Connections \\--
        do
            LockedHover.MouseEnter:Connect(function()
                LockedIcon.Visible = true
            end)

            LockedHover.MouseLeave:Connect(function()
                LockedIcon.Visible = false
            end)

            ActualButton.MouseEnter:Connect(function()
                Button.Hovering = true

                ButtonStroke.Color = hoveringToggleColor
                if not Button.Clicking then
                    ActualButton.TextTransparency = 0.25
                end
            end)

            ActualButton.MouseLeave:Connect(function()
                Button.Hovering = false

                ButtonStroke.Color = defaultToggleColor
                if not Button.Clicking then
                    ActualButton.TextTransparency = 0.5
                end
            end)

            ActualButton.MouseButton1Click:Connect(function()
                if Button.Locked then return end

                if Button.DoubleClick then
                    if Button.Clicking then
                        Button:SetClicking(false)
                        
                        Button.TimesClicked += 1
                        Midnight:SafeCallback(options.Callback, Button.TimesClicked)
                    else
                        Button:SetClicking(true)

                        task.delay(0.5, function()
                            if Button.Clicking then
                                Button:SetClicking(false)
                            end
                        end)
                    end

                    return
                end

                Button.TimesClicked += 1
                Midnight:SafeCallback(options.Callback, Button.TimesClicked)
            end)
        end

        return Button
    end

    function Components:AddToggle(options: ToggleOptions)
        --// Toggle Holder \\--
        local ToggleHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 13),
            Parent = ToggleHolder
        })
        
        --// Toggle Text \\--
        local ToggleText: TextLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Toggle",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ToggleHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 36),
            PaddingTop = UDim.new(0, 6),
            Parent = ToggleText
        })

        --// Toggle Button \\--
        local ToggleButton: TextButton = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(32, 16),
            Text = "",
            Parent = ToggleHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ToggleButton
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = ToggleButton,
        })

        local ToggleStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ToggleButton
        })

        --// Toggle Icon \\--
        local ToggleIcon = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = ToggleButton
        })

        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ToggleIcon
        })

        --// Locked \\--
        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072718362",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, 12, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            Visible = false,
            Parent = ToggleHolder
        })

        local LockedHover: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Visible = false,
            Parent = ToggleHolder,
        })

        --// Toggle Table \\--
        local Toggle = {
            Hovering = false,
            Locked = false,
            
            Value = options.Value or false,

            Type = "Toggle"
        }

        function Toggle:SetLocked(locked: boolean)
            Toggle.Locked = locked
            
            LockedHover.Visible = Toggle.Locked
            if Toggle.Hovering then
                ToggleButton.Visible = not Toggle.Locked
                LockedIcon.Visible = Toggle.Locked
            end
        end

        function Toggle:Set(newValue: boolean)
            local oldValue = Toggle.Value
            Toggle.Value = newValue

            ToggleIcon.BackgroundColor3 = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)
            ToggleIcon.Position = Toggle.Value and UDim2.fromOffset(16, 0) or UDim2.fromOffset(0, 0)

            ToggleStroke.Color = Toggle.Value and enabledToggleColor or (Toggle.Hovering and hoveringToggleColor or defaultToggleColor)

            if Toggle.Value ~= oldValue then
                Midnight:SafeCallback(options.Callback, Toggle.Value, oldValue)
                
            end
        end

        --// Toggle Connections \\--
        do
            if options.Flag then
                Midnight.Flags[options.Flag] = Toggle
            end

            LockedHover.MouseEnter:Connect(function()
                ToggleButton.Visible = false
                LockedIcon.Visible = true
            end)

            LockedHover.MouseLeave:Connect(function()
                LockedIcon.Visible = false
                ToggleButton.Visible = true
            end)

            ToggleButton.MouseEnter:Connect(function()
                Toggle.Hovering = true

                if not Toggle.Value and not Toggle.Locked then
                    ToggleIcon.BackgroundColor3 = hoveringToggleColor
                    ToggleStroke.Color = hoveringToggleColor
                end
            end)

            ToggleButton.MouseLeave:Connect(function()
                Toggle.Hovering = false

                if not Toggle.Value and not Toggle.Locked then
                    ToggleIcon.BackgroundColor3 = defaultToggleColor
                    ToggleStroke.Color = defaultToggleColor
                end
            end)

            ToggleButton.MouseButton1Click:Connect(function()
                if Toggle.Locked then return end
                Toggle:Set(not Toggle.Value)
            end)

            Toggle:Set(Toggle.Value)
        end

        return Toggle
    end

    function Components:AddSlider(options: SliderOptions)
        --// Slider Holder \\--
        local SliderHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            Parent = SliderHolder
        })

        --// Slider Text \\--
        local SliderText = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, -48, 0, 32),
            Text = options.Name or "No Name",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = SliderHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = SliderText
        })

        --// Slider Value \\--
        local SliderValue: TextBox = Create("TextBox", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Position = UDim2.new(1, 0, 0, 8),
            Size = UDim2.fromOffset(48, 18),
            Text = "100",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = SliderHolder
        })

        --// Locked Icon \\--
        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072718362",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, 6, 0, 7),
            Size = UDim2.fromOffset(20, 20),
            Visible = false,
            Parent = SliderHolder
        })

        --// Locked Hover \\--
        local LockedHover: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Visible = false,
            Parent = SliderHolder,
        })

        --// Slider Bar \\--
        local SliderBar: TextButton = Create("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Position = UDim2.new(0, 0, 1, -10),
            Size = UDim2.new(1, 0, 0, 6),
            Text = "",
            Parent = SliderHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SliderBar
        })

        --// Slider Fill Bar \\--
        local SliderFillBar = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(140, 140, 140),
            Size = UDim2.fromScale(0.5, 1),
            Parent = SliderBar
        })

        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SliderFillBar
        })

        --// Slider Table \\--
        local Slider = {
            Dragging = false,
            Hovering = false,
            Locked = false,

            Increment = options.Increment or 1,
            Min = options.Min or 0,
            Max = options.Max or 100,
            Value = options.Value or (options.Min or 0),

            Type = "Slider"
        }

        function Slider:Set(newValue: number)
            local oldValue = Slider.Value
            Slider.Value = math.floor(math.clamp(Round(newValue, Slider.Increment), Slider.Min, Slider.Max) * (100 * Slider.Max)) / (100 * Slider.Max)

            SliderValue.Text = tostring(Slider.Value)
            SliderFillBar.Size = UDim2.fromScale((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)

            if Slider.Value ~= oldValue then
                Midnight:SafeCallback(options.Callback, Slider.Value, oldValue)
            end
        end

        function Slider:SetLocked(locked: boolean)
            Slider.Locked = locked

            LockedHover.Visible = Slider.Locked
            if Slider.Hovering then
                SliderValue.Visible = not Slider.Locked
                LockedIcon.Visible = Slider.Locked
            end
        end

        function Slider:SetMin(newMin: number)
            if newMin > Slider.Max then
                return warn("Slider minimum value should be smaller than maximum value")
            end

            Slider.Min = newMin
            Slider:Set(math.clamp(Slider.Value, Slider.Min, Slider.Max))
        end

        function Slider:SetMax(newMax: number)
            if newMax < Slider.Min then
                return warn("Slider maximum value should be higher than minimum value")
            end

            Slider.Max = newMax
            Slider:Set(math.clamp(Slider.Value, Slider.Min, Slider.Max))
        end

        do
            local dragInput

            if options.Flag then
                Midnight.Flags[options.Flag] = Slider
            end

            SliderValue.FocusLost:Connect(function(enterPressed)
                local newValue = tonumber(SliderValue.Text)

                if newValue and enterPressed then
                    newValue = math.clamp(newValue, Slider.Min, Slider.Max)

                    Slider:Set(newValue)
                else
                    SliderValue.Text = Slider.Value
                end
            end)

            LockedHover.MouseEnter:Connect(function()
                SliderValue.Visible = false
                LockedIcon.Visible = true
            end)

            LockedHover.MouseLeave:Connect(function()
                LockedIcon.Visible = false
                SliderValue.Visible = true
            end)

            SliderBar.MouseEnter:Connect(function()
                Slider.Hovering = true
            end)

            SliderBar.MouseLeave:Connect(function()
                Slider.Hovering = true
            end)

            SliderBar.InputBegan:Connect(function(input: InputObject)
                if not Slider.Locked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    Slider.Dragging = true

                    local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    Slider:Set(Slider.Min + ((Slider.Max - Slider.Min) * percentage))

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            Slider.Dragging = false
                        end
                    end)
                end
            end)

            Midnight:AddConnection(UserInputService.InputChanged:Connect(function(input: InputObject)
                if not Midnight.Opened then 
                    Slider.Dragging = false
                    return
                end

                if Slider.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    Slider:Set(Slider.Min + ((Slider.Max - Slider.Min) * percentage))
                end
            end))

            Slider:Set(Slider.Value)
        end

        return Slider
    end

    function Components:AddTextbox(options: TextboxOptions)
        --// Textbox Holder \\--
        local TextboxHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight  = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = TextboxHolder
        })

        --// Locked \\--
        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072718362",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            Visible = false,
            Parent = TextboxHolder
        })

        --// Box \\--
        local Box: TextBox = Create("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = options.ResetOnFocus or false,
            FontFace = regularFont,
            PlaceholderColor3 = Color3.fromRGB(60, 60, 60),
            PlaceholderText = options.Name or "No Name",
            Size = UDim2.fromScale(1, 1),
            Text = options.Text or "",
            TextColor3 = Color3.fromRGB(140, 140, 140),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TextboxHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Box
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = Box
        })

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = Box
        })

        local Textbox = {
            Hovering = false,
            Locekd = false,

            Text = options.Text or "",

            Type = "Textbox"
        }

        function Textbox:Set(newText: string)
            local oldText = Textbox.Text
            Textbox.Text = newText

            Box.Text = Textbox.Text
            if Box.Text ~= oldText then
                Midnight:SafeCallback(options.Callback, Box.Text, oldText)
            end
        end

        function Textbox:SetLocked(locked: boolean)
            Textbox.Locked = locked

            Box.TextEditable = not Textbox.Locked
            LockedIcon.Visible = Textbox.Hovering and Textbox.Locked
        end

        do
            if options.Flag then
                Midnight.Flags[options.Flag] = Textbox
            end

            Box.MouseEnter:Connect(function()
                Textbox.Hovering = true

                LockedIcon.Visible = Textbox.Locked
            end)

            Box.MouseLeave:Connect(function()
                Textbox.Hovering = false

                LockedIcon.Visible = false
            end)

            Box:GetPropertyChangedSignal("Text"):Connect(function()
                local oldText = Textbox.Text
                Textbox.Text = Box.Text

                if Box.Text ~= oldText then
                    Midnight:SafeCallback(options.Callback, Box.Text, oldText)
                end 
            end)
        end

        return Textbox
    end

    function Components:AddDropdown(options: DropdownOptions)
        --// Dropdown Holder \\--
        local DropdownHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = DropdownHolder
        })

        --// Buttons Holder \\--
        local ButtonsHolder = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(1, 0, 0, 32),
            Parent = DropdownHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = ButtonsHolder
        })

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ButtonsHolder
        })

        --// Current Button \\--
        local CurrentButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, 0, 0, 32),
            TextColor3 = Color3.fromRGB(140, 140, 140),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 30),
            PaddingTop = UDim.new(0, 6),
            Parent = CurrentButton
        })

        --// Options Holder \\--
        local OptionsHolder = Create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = ButtonsHolder,
        })

        local OptionsListLayout = Create("UIListLayout", {
            Parent = OptionsHolder,
        })

        --// Icon \\--
        local Icon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072706663",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -5, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            Parent = DropdownHolder
        })

        --// Locked \\--
        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072718362",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -5, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            Visible = false,
            Parent = DropdownHolder
        })

        local LockedHover = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = DropdownHolder,
        })

        --// Dropdown Table \\--
        local Dropdown = {
            Buttons = {},
            FinalText = "",
            Locked = false,
            Hovering = false,
            Opened = false,

            AllowNull = true,
            Multi = options.Multi or false,
            Name = options.Name or "Dropdown",
            Value = options.Multi and {} or nil,
            Values = options.Values or {},
            
            Type = "Dropdown"
        }

        function Dropdown:BuildList()
            table.clear(Dropdown.Buttons)

            for _, oldButtons in pairs(OptionsHolder:GetChildren()) do
                if oldButtons:IsA("TextButton") then
                    oldButtons:Destroy()
                end
            end

            if Dropdown.Multi then
                for valueName, _ in pairs(Dropdown.Value) do
                    if not table.find(Dropdown.Values, valueName) then
                        Dropdown.Value[valueName] = nil
                    end
                end
            else
                if not table.find(Dropdown.Values, Dropdown.Value) then
                    Dropdown.Value = nil
                end
            end  

            for _, value in pairs(Dropdown.Values) do
                local Button: TextButton = Create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    FontFace = regularFont,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = value,
                    TextColor3 = Color3.fromRGB(140, 140, 140),
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = OptionsHolder
                })

                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = Button
                })

                local selected

                if Dropdown.Multi then
                    selected = Dropdown.Value[value]
                else
                    selected = Dropdown.Value == value
                end

                local Table = {}

                function Table:UpdateButton()
                    if Dropdown.Multi then
                        selected = Dropdown.Value[value]
                    else
                        selected = Dropdown.Value == value
                    end

                    Button.TextColor3 = selected and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 140)
                end

                do
                    Button.MouseButton1Click:Connect(function()
                        if Dropdown.Locked or (selected and Dropdown:GetSelectedValues() == 1 and not Dropdown.AllowNull) then return end
                        
                        local oldValue = Dropdown.Multi and table.clone(Dropdown.Value) or Dropdown.Value
                        selected = not selected

                        if Dropdown.Multi then
                            Dropdown.Value[value] = selected and true or nil
                        else
                            Dropdown.Value = selected and value or nil

                            for _, otherButton in pairs(Dropdown.Buttons) do
                                otherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Update()

                        Midnight:SafeCallback(options.Callback, Dropdown.Value, oldValue)
                    end)

                    Table:UpdateButton()
                    Dropdown:Update()
                end

                Dropdown.Buttons[value] = Table
            end
        end
        
        function Dropdown:GetSelectedValues()
            if Dropdown.Multi then
                local values = {}

                for valueName, _ in pairs(Dropdown.Value) do
                    table.insert(values, valueName)
                end

                return #values
            else
                return Dropdown.Value and 1 or 0
            end
        end

        function Dropdown:SetValue(newValue)
            local oldValue = Dropdown.Multi and table.clone(Dropdown.Value) or Dropdown.Value

            if Dropdown.Multi then
                local valueTable = {}

                for valueName, valueBool in pairs(newValue) do
                    if valueBool and table.find(Dropdown.Values, valueName) then
                        valueTable[valueName] = true
                    end
                end

                Dropdown.Value = valueTable
            else
                if not newValue then
                    Dropdown.Value = nil
                elseif table.find(Dropdown.Values, newValue) then
                    Dropdown.Value = newValue
                end
            end

            Dropdown:Update()
            Dropdown:UpdateButtons()

            Midnight:SafeCallback(options.Callback, Dropdown.Value, oldValue)
        end

        function Dropdown:SetValues(newValues)
            Dropdown.Values = newValues

            Dropdown:BuildList()
        end

        function Dropdown:SetLocked(locked)
            Dropdown.Locked = locked

            LockedHover.Visible = Dropdown.Locked
            if Dropdown.Hovering then
                Icon.Visible = not Dropdown.Locked
                LockedIcon.Visible = Dropdown.Locked
            end
        end

        function Dropdown:Update()
            local finalText = ""

            if Dropdown.Multi then
                for _, value in pairs(Dropdown.Values) do
                    if Dropdown.Value[value] then
                        finalText = finalText .. value .. ", "
                    end
                end

                finalText = finalText:sub(1, #finalText - 2)
            else
                finalText = Dropdown.Value or ""
            end

            CurrentButton.Text = Dropdown.Name .. (finalText == "" and "" or ": ") .. finalText
        end

        function Dropdown:UpdateButtons()
            for _, button in pairs(Dropdown.Buttons) do
                button:UpdateButton()
            end
        end

        function Dropdown:Toggle()
            Dropdown.Opened = not Dropdown.Opened

            Icon.Image = Dropdown.Opened and "rbxassetid://7072706796" or "rbxassetid://7072706663"

            if Dropdown.Opened then
                DropdownHolder.Size = UDim2.new(1, 0, 0, 42 + OptionsListLayout.AbsoluteContentSize.Y)
                ButtonsHolder.Size = UDim2.new(1, 0, 0, 32 + OptionsListLayout.AbsoluteContentSize.Y)
                OptionsHolder.Visible = true
            else
                OptionsHolder.Visible = false
                ButtonsHolder.Size = UDim2.new(1, 0, 0, 32)
                DropdownHolder.Size = UDim2.new(1, 0, 0, 42)
            end
        end

        do
            if options.Flag then
                Midnight.Flags[options.Flag] = Dropdown
            end

            if options.AllowNull == false then Dropdown.AllowNull = false end

            OptionsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Dropdown.Opened then
                    DropdownHolder.Size = UDim2.new(1, 0, 0, 52 + OptionsListLayout.AbsoluteContentSize.Y)
                    ButtonsHolder.Size = UDim2.new(1, 0, 0, OptionsListLayout.AbsoluteContentSize.Y + 32)
                end
            end)

            LockedHover.MouseEnter:Connect(function()
                Icon.Visible = false
                LockedIcon.Visible = true
            end)

            LockedHover.MouseLeave:Connect(function()
                LockedIcon.Visible = false
                Icon.Visible = true
            end)

            CurrentButton.MouseEnter:Connect(function()
                Dropdown.Hovering = true
            end)

            CurrentButton.MouseLeave:Connect(function()
                Dropdown.Hovering = false
            end)

            CurrentButton.MouseButton1Click:Connect(function()
                Dropdown:Toggle()
            end)

            Dropdown:BuildList()
            Dropdown:Update()

            task.spawn(function()
                local currentValue = {}

                if type(options.Value) == "string" then
                    local index = table.find(Dropdown.Values, options.Value)
                    if index then
                        table.insert(currentValue, index)
                    end
                elseif type(options.Value) == "table" then
                    for _, value in pairs(options.Value) do
                        local index = table.find(Dropdown.Values, value)
                        if index then
                            table.insert(currentValue, index)
                        end
                    end
                elseif type(options.Value) == 'number' and Dropdown.Values[options.Value] ~= nil then
                    table.insert(currentValue, options.Value)
                end

                if pairs(currentValue) then
                    for i = 1, #currentValue do
                        local index = currentValue[i]
                        if Dropdown.Multi then
                            Dropdown.Value[Dropdown.Values[index]] = true
                        else
                            Dropdown.Value = Dropdown.Values[index]
                        end

                        if not Dropdown.Multi then break end
                    end
                end

                Dropdown:BuildList()
                Dropdown:Update()
            end)
        end
        
        return Dropdown
    end

    function Components:AddKeyPicker(options: KeyPickerOptions)
        --// KeyPicker Holder \\--
        local KeyPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = self.Container,
        })

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            Parent = KeyPickerHolder
        })

        --// KeyPicker Text \\--
        local KeyPickerText = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = options.Name or "Key Picker",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = KeyPickerHolder,
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = KeyPickerText
        })

        --// KeyPicker Button \\--
        local KeyPickerButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 0.95,
            FontFace = semiBoldFont,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(20, 20),
            Text = "...",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = KeyPickerHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = KeyPickerButton
        })

        local KeyPicker = {
            Hovering = false,
            KeyPressed = nil,
            State = false,
            Picking = false,

            Keybind = options.Keybind or nil,
            Mode = options.Mode or "Toggle",

            Type = "KeyPicker",
        }

        function KeyPicker:SetKeybind(keybind: Enum.KeyCode | Enum.UserInputType, picking)
            KeyPicker.Keybind = keybind

            KeyPicker:Update(KeyPicker.Keybind, picking)
        end

        function KeyPicker:SetState(state: boolean)
            local oldState = KeyPicker.State
            KeyPicker.State = state

            if KeyPicker.State ~= oldState then
                Midnight:SafeCallback(options.Callback, KeyPicker.State, oldState)
            end
        end

        function KeyPicker:Update(keybind, picking)
            local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")

            local params = Instance.new("GetTextBoundsParams")
            params.Font = semiBoldFont
            params.Size = 14
            params.Text = keyText
            params.Width = Midnight.UISize - 24

            local size = TextService:GetTextBoundsAsync(params)

            KeyPickerButton.Size = UDim2.fromOffset(size.X + 12, 20)
            KeyPickerButton.Text = keyText
        end

        do
            if options.Flag then
                Midnight.Flags[options.Flag] = KeyPicker
            end

            KeyPickerButton.MouseEnter:Connect(function()
                KeyPicker.Hovering = true

                KeyPickerButton.TextTransparency = 0.25
            end)

            KeyPickerButton.MouseLeave:Connect(function()
                KeyPicker.Hovering = false

                KeyPickerButton.TextTransparency = 0.5
            end)

            KeyPickerButton.MouseButton1Click:Connect(function()
                if KeyPicker.Picking then return end
            
                KeyPicker.Picking = true
                KeyPicker:SetKeybind(nil, true)

                local inputObject = UserInputService.InputBegan:Wait()
                local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown

                if isKeyCode and inputObject.KeyCode == Enum.KeyCode.Escape then
                    KeyPicker:SetKeybind(nil)
                    KeyPicker.Picking = false
                    return
                end

                KeyPicker.KeyPressed = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
                KeyPicker:SetKeybind(KeyPicker.KeyPressed)
            end)

            Midnight:AddConnection(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
                if (input.KeyCode == KeyPicker.Keybind or input.UserInputType == KeyPicker.Keybind) and not KeyPicker.Picking and not gameProcessedEvent then
                    if KeyPicker.Mode == "Hold" then
                        KeyPicker:SetState(true)
                    else
                        KeyPicker:SetState(not KeyPicker.State)
                    end
                end
            end))

            Midnight:AddConnection(UserInputService.InputEnded:Connect(function(input: InputObject)
                if (input.KeyCode == KeyPicker.Keybind or input.UserInputType == KeyPicker.Keybind) and not KeyPicker.Picking then
                    if KeyPicker.Mode == "Hold" then
                        KeyPicker:SetState(false)
                    end
                elseif (input.KeyCode == KeyPicker.KeyPressed or input.UserInputType == KeyPicker.KeyPressed) and KeyPicker.Picking then
                    KeyPicker.KeyPressed = nil
                    KeyPicker.Picking = false
                end
            end))

            KeyPicker:SetKeybind(KeyPicker.Keybind)
        end

        return KeyPicker
    end

    function Components:AddColorPicker(options: ColorPickerOptions)
        --// ColorPicker Holder \\--
        local ColorPickerHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Parent = self.Container
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 13),
            PaddingRight = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 5),
            Parent = ColorPickerHolder
        })

        --// Buttons Holder \\--
        local ButtonsHolder = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.fromScale(1, 1),
            Parent = ColorPickerHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = ButtonsHolder
        })

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(60, 60, 60),
            Parent = ButtonsHolder
        })

        --// Open Button \\--
        local OpenButton: TextButton = Create("TextButton", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.new(1, 0, 0, 32),
            Text = options.Name or "No Name",
            TextColor3 = Color3.fromRGB(140, 140, 140),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 30),
            PaddingTop = UDim.new(0, 6),
            Parent = OpenButton
        })

        --// Color Holder \\--
        local ColorHolder = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 1, -32),
            Visible = false,
            Parent = ButtonsHolder
        })

        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ColorHolder
        })

        --// Color Image \\--
        local ColorImage = Create("ImageLabel", {
            BackgroundColor3 = options.Color or Color3.new(1, 1, 1),
            Image = "rbxassetid://4155801252",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = ColorHolder
        })

        --// Color Image Indicator \\--
        local ColorImageIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.fromOffset(6, 6),
            Parent = ColorImage
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = ColorImageIndicator
        })

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.new(0, 0, 0),
            Parent = ColorImageIndicator
        })

        --// Color Hue \\--
        local ColorHue: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 16, 1, 0),
            Text = "",
            Parent = ColorHolder
        })

        Create("UIGradient", {
            Color = ColorSequence.new(hueSequenceTable),
            Rotation = 90,
            Parent = ColorHue
        })

        --// Color Hue Indicator \\--
        local ColorHueIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 2, 0, 2),
            Parent = ColorHue
        })

        --// Color Indicator \\--
        local ColorIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = options.Color or Color3.new(1, 1, 1),
            Position = UDim2.new(1, -6, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            Parent = ColorPickerHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = ColorIndicator
        })

        --// Locked \\--
        local LockedIcon = Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072718362",
            ImageColor3 = options.Color or Color3.new(1, 1, 1),
            Position = UDim2.new(1, -5, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            Visible = false,
            Parent = ColorPickerHolder
        })

        local LockedHover = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = ColorPickerHolder,
        })

        --// ColorPicker Table \\--
        local ColorPicker = {
            DraggingColor = false,
            DraggingHue = false,
            Locked = false,
            Hovering = false,
            Opened = false,

            Hue = 0,
            Sat = 0,
            Vib = 0,
            Color = options.Color or Color3.new(1, 1, 1),

            Type = "ColorPicker"
        }

        
        function ColorPicker:SetColor(newColor: Color3)
            local h, s, v = newColor:ToHSV()
            
            ColorPicker.Hue = h
            ColorPicker.Sat = s
            ColorPicker.Vib = v

            ColorPicker:Update()
        end

        function ColorPicker:SetColorHSV(hsv)
            local newColor = Color3.fromHSV(hsv[1], hsv[2], hsv[3])
            ColorPicker:SetColor(newColor)
        end

        function ColorPicker:SetLocked(locked)
            ColorPicker.Locked = locked

            LockedHover.Visible = ColorPicker.Locked
            if ColorPicker.Hovering then
                ColorIndicator.Visible = not ColorPicker.Locked
                LockedIcon.Visible = ColorPicker.Locked
            end
        end

        function ColorPicker:Toggle()
            ColorPicker.Opened = not ColorPicker.Opened

            if ColorPicker.Opened then
                ColorPickerHolder.Size = UDim2.new(1, 0, 0, Midnight.UISize - 8)
                ColorHolder.Visible = true
            else
                ColorHolder.Visible = false
                ColorPickerHolder.Size = UDim2.new(1, 0, 0, 42)
            end
        end

        function ColorPicker:Update()
            local oldColor = ColorPicker.Color
            ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            ColorImage.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            ColorIndicator.BackgroundColor3 = ColorPicker.Color

            ColorImageIndicator.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0)
            ColorHueIndicator.Position = UDim2.fromScale(0.5, ColorPicker.Hue)

            LockedIcon.ImageColor3 = ColorPicker.Color

            if ColorPicker.Color ~= oldColor then
                Midnight:SafeCallback(options.Callback, ColorPicker.Color, oldColor)
            end
        end

        do
            if options.Flag then
                Midnight.Flags[options.Flag] = ColorPicker
            end

            LockedHover.MouseEnter:Connect(function()
                ColorPicker.DraggingColor = false
                ColorPicker.DraggingHue = false

                ColorIndicator.Visible = false
                LockedIcon.Visible = true
            end)

            LockedHover.MouseLeave:Connect(function()
                LockedIcon.Visible = false
                ColorIndicator.Visible = true
            end)

            OpenButton.MouseEnter:Connect(function()
                ColorPicker.Hovering = true
            end)

            OpenButton.MouseLeave:Connect(function()
                ColorPicker.Hovering = false
            end)

            OpenButton.MouseButton1Click:Connect(function()
                ColorPicker:Toggle()
            end)

            ColorImage.InputBegan:Connect(function(input: InputObject)
                if not ColorPicker.Locked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    ColorPicker.DraggingColor = true

                    local minX = ColorImage.AbsolutePosition.X
                    local maxX = minX + ColorImage.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X, minX, maxX)

                    local minY = ColorImage.AbsolutePosition.Y
                    local maxY = minY + ColorImage.AbsoluteSize.Y
                    local mouseY = math.clamp(input.Position.Y, minY, maxY)

                    ColorPicker.Sat = (mouseX - minX) / (maxX - minX)
                    ColorPicker.Vib = 1 - (mouseY - minY) / (maxY- minY)

                    ColorPicker:Update()

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            ColorPicker.DraggingColor = false
                        end
                    end)
                end
            end)

            ColorHue.InputBegan:Connect(function(input: InputObject)
                if not ColorPicker.Locked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    ColorPicker.DraggingHue = true

                    local minY = ColorImage.AbsolutePosition.Y
                    local maxY = minY + ColorImage.AbsoluteSize.Y
                    local mouseY = math.clamp(input.Position.Y, minY, maxY)

                    ColorPicker.Hue = ((mouseY - minY)) / (maxY - minY)

                    ColorPicker:Update()

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            ColorPicker.DragginHue = false
                        end
                    end)
                end
            end)

            Midnight:AddConnection(UserInputService.InputChanged:Connect(function(input: InputObject)
                if not Midnight.Opened then 
                    ColorPicker.DraggingColor = false 
                    ColorPicker.DraggingHue = false
                    return
                end

                if ColorPicker.DraggingColor then
                    local minX = ColorImage.AbsolutePosition.X
                    local maxX = minX + ColorImage.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X, minX, maxX)

                    local minY = ColorImage.AbsolutePosition.Y
                    local maxY = minY + ColorImage.AbsoluteSize.Y
                    local mouseY = math.clamp(input.Position.Y, minY, maxY)

                    ColorPicker.Sat = (mouseX - minX) / (maxX - minX)
                    ColorPicker.Vib = 1 - (mouseY - minY) / (maxY- minY)

                    ColorPicker:Update()
                elseif ColorPicker.DraggingHue then
                    local minY = ColorHue.AbsolutePosition.Y
                    local maxY = minY + ColorHue.AbsoluteSize.Y
                    local mouseY = math.clamp(input.Position.Y, minY, maxY)

                    ColorPicker.Hue = ((mouseY - minY)) / (maxY - minY)
                    
                    ColorPicker:Update()
                end
            end))

            ColorPicker:SetColor(options.Color)
        end

        return ColorPicker
    end
    
    BaseComponents.__index = Components
    BaseComponents.__namecall = function(Table, Key, ...)
        return Components[Key](...)
    end
end


function Midnight:SafeCallback(f, ...)
    if not f then
        return
    end

    local success, error = pcall(f, ...)
    if not success then
        warn("Midnight |", error)
    end
end

function Midnight:AddConnection(connection)
    table.insert(Midnight.Connections, connection)
end

function Midnight:CreateWindow(options: WindowOptions)
    Midnight.NotifySound = options.NotifySound or 4590657391
    Midnight.NotifyVolume = options.NotifyVolume or 2

    Midnight.SaveFolder = options.SaveFolder or "MidnightLibrary"
    Midnight.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightShift

    if options.Blur ~= false then
        Midnight.Blur = Create("BlurEffect", {
            Size = 12,
            Parent = Lighting
        })
    end

    --// Main Window \\--
    local MainWindow = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.fromOffset(Midnight.UISize, 0),
        Parent = Windows
    })
    table.insert(Midnight.Tabs, MainWindow)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainWindow
    })

    Create("UIListLayout", {
        Parent = MainWindow
    })

    --// Top \\--
    local Top = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainWindow
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Top
    })

    Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(1, 0.25),
        Parent = Top
    })

    --// Title \\--
    local Title = Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = semiBoldFont,
        Size = UDim2.fromScale(1, 1),
        Text = options.Title or "No Title",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Title
    })

    --// Separator \\--
    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = MainWindow
    })

    --// Tab Buttons \\--
    local TabButtons = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Parent = MainWindow
    })

    Create("UIListLayout", {
        Parent = TabButtons
    })

    --// Separator \\--
    Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = MainWindow
    })

    --// Extra \\-
    Create("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = 999,
        Size = UDim2.new(1, 0, 0, 6),
        Parent = MainWindow
    })

    task.spawn(Midnight.Toggle)

    local Window = {}

    function Window:AddTab(tabName: string)
        --// Tab Holder \\--
        local TabHolder: Frame = Create("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Position = UDim2.fromOffset((Midnight.UISize + 6) * #Midnight.Tabs, 0),
            Size = UDim2.fromOffset(Midnight.UISize, 0),
            Visible = false,
            Parent = Windows,
        })
        table.insert(Midnight.Tabs, MainWindow)
    
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabHolder
        })
    
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabHolder
        })
    
        --// Top \\--
        local Top = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "",
            Parent = TabHolder
        })
    
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Top
        })
    
        Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Position = UDim2.fromScale(0.5, 1),
            Size = UDim2.fromScale(1, 0.25),
            Parent = Top
        })
    
        --// Tab Title \\--
        local Title = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = mediumFont,
            Size = UDim2.fromScale(1, 1),
            Text = tabName or "No Name",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Top
        })
    
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 6),
            Parent = Title
        })
    
        --// Separator \\--
        Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Size = UDim2.new(1, 0, 0, 1),
            Parent = TabHolder
        })
    
        --// Elements \\--
        local Elements = Create("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
            ScrollBarThickness = 4,
            Size = UDim2.fromScale(1, 0),
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Parent = TabHolder
        })
    
        local ElementsListLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Elements
        })
    
        --// Separator \\--
        Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Size = UDim2.new(1, 0, 0, 1),
            Parent = TabHolder
        })
    
        --// Extra \\-
        Create("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 999,
            Size = UDim2.new(1, 0, 0, 6),
            Parent = TabHolder
        })
    

        --// Tab Button \\--
        local TabButton: TextButton = Create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            Parent = TabButtons
        })

        local TabButtonText = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = regularFont,
            Size = UDim2.fromScale(1, 1),
            Text = tabName or "No Name",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })

        Create("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072706745",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            ZIndex = 2,
            Parent = TabButton
        })
    
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 11),
            PaddingRight = UDim.new(0, 11),
            PaddingTop = UDim.new(0, 8),
            Parent = TabButtonText
        })

        --// Tab Table \\--
        local Tab = {
            Hovering = false,
            Opened = false
        }

        function Tab:Toggle()
            Tab.Opened = not Tab.Opened

            TabHolder.Visible = Tab.Opened

            TabButton.BackgroundColor3 = Tab.Opened and Color3.fromRGB(35, 35, 35) or (Tab.Hovering and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(25, 25, 25))
            TabButtonText.TextTransparency = Tab.Opened and 0 or (Tab.Hovering and 0.25 or 0.5)
        end

        --// Add Elements \\--
        function Tab:AddElementSection(name: string)
            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                Parent = Elements
            })

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                FontFace = regularFont,
                Size = UDim2.new(1, 0, 0, 36),
                Text = name or "Section",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ElementHolder
            })

            --// Components Holder \\--
            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.new(1, 0, 1, -36),
                Parent = ElementHolder
            })

            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Components
            })
            
            local Icon: ImageLabel = Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7072719531",
                ImageTransparency = 0.5,
                Position = UDim2.new(1, -4, 0, 8),
                Size = UDim2.fromOffset(20, 20),
                ZIndex = 2,
                Parent = ElementHolder
            })

            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8), 
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11),
                PaddingTop = UDim.new(0, 8),
                Parent = ButtonFrame
            })

            --// Element Section Table \\--
            local ElementSection = {
                Container = Components,
                Opened = false
            }

            function ElementSection:Toggle()
                ElementSection.Opened = not ElementSection.Opened

                ElementHolder.Size = ElementSection.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
            end

            --// Element Holder Connections \\--
            do
                ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ElementHolder.Size = ElementSection.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
                end)

                ButtonFrame.MouseEnter:Connect(function()
                    ElementSection.Hovering = true
                    
                    ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    ButtonFrame.TextTransparency = 0.25
                end)
    
                ButtonFrame.MouseLeave:Connect(function()
                    ElementSection.Hovering = false

                    ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    ButtonFrame.TextTransparency = 0.5
                end)

                ButtonFrame.MouseButton2Click:Connect(function()
                    ElementSection:Toggle()
                end)

                setmetatable(ElementSection, BaseComponents)
            end

            return ElementSection
        end

        function Tab:AddElementButton(options: ElementButtonOptions)
            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                Parent = Elements
            })

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                FontFace = regularFont,
                Size = UDim2.new(1, 0, 0, 36),
                Text = options.Name or "Button",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ElementHolder
            })

            --// Keybind Button \\--
            local KeybindButton: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 0.95,
                FontFace = semiBoldFont,
                Position = UDim2.new(1, -28, 0, 8),
                Size = UDim2.fromOffset(20, 20),
                Text = "...",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = ElementHolder
            })

            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = KeybindButton
            })

            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.new(1, 0, 1, -36),
                Parent = ElementHolder
            })

            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Components
            })
            
            local Icon: ImageLabel = Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7072719531",
                ImageTransparency = 0.5,
                Position = UDim2.new(1, -4, 0, 8),
                Size = UDim2.fromOffset(20, 20),
                ZIndex = 2,
                Parent = ElementHolder
            })

            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8), 
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11),
                PaddingTop = UDim.new(0, 8),
                Parent = ButtonFrame
            })

            --// Element Button Table \\--
            local ElementButton = {
                Container = Components,
                Hovering = false,
                KeyPressed = nil,
                Locked = false,
                Opened = false,
                Picking = false,
                TimesClicked = 0,

                Name = options.Name or "Button",
                
                Keybind = options.Keybind or nil,

                Type = "ElementButton"
            }

            function ElementButton:SetKeybind(keybind: Enum.KeyCode | Enum.UserInputType, picking)                
                ElementButton.Keybind = keybind

                ElementButton:UpdateKeybind(ElementButton.Keybind, picking)
            end

            function ElementButton:UpdateKeybind(keybind, picking)
                local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")

                local params = Instance.new("GetTextBoundsParams")
                params.Font = semiBoldFont
                params.Size = 14
                params.Text = keyText
                params.Width = Midnight.UISize - 24

                local size = TextService:GetTextBoundsAsync(params)

                KeybindButton.Size = UDim2.fromOffset(size.X + 12, 20)
                KeybindButton.Text = keyText
            end

            function ElementButton:SetLocked(locked: boolean)
                ElementButton.Locked = locked

                if ElementButton.Hovering then
                    Icon.Position = ElementButton.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                    Icon.Image = ElementButton.Locked and "rbxassetid://7072718362" or "rbxassetid://7072719531"
                end
            end

            function ElementButton:Toggle()
                ElementButton.Opened = not ElementButton.Opened

                ElementHolder.Size = ElementButton.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
            end

            --// Element Button Connections \\--
            do
                ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ElementHolder.Size = ElementButton.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
                end)

                ButtonFrame.MouseEnter:Connect(function()
                    ElementButton.Hovering = true
                    Icon.Position = ElementButton.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                    Icon.Image = ElementButton.Locked and "rbxassetid://7072718362" or "rbxassetid://7072719531"
                    
                    if not ElementButton.Locked then
                        ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        ButtonFrame.TextTransparency = 0.25
                    end
                end)
    
                ButtonFrame.MouseLeave:Connect(function()
                    ElementButton.Hovering = false
                    Icon.Image = "rbxassetid://7072719531"
                    Icon.Position = UDim2.new(1, -4, 0, 8)

                    if not ElementButton.Locked then
                        ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        ButtonFrame.TextTransparency = 0.5
                    end
                end)
    
                ButtonFrame.MouseButton1Click:Connect(function()
                    if ElementButton.Locked then return end
                    ElementButton.TimesClicked += 1
                    Midnight:SafeCallback(options.Callback, ElementButton.TimesClicked)
                end)

                ButtonFrame.MouseButton2Click:Connect(function()
                    ElementButton:Toggle()
                end)

                KeybindButton.MouseEnter:Connect(function()
                    KeybindButton.TextTransparency = 0.25
                end)

                KeybindButton.MouseLeave:Connect(function()
                    KeybindButton.TextTransparency = 0.5
                end)

                KeybindButton.MouseButton1Click:Connect(function()
                    if ElementButton.Picking then return end
                    
                    ElementButton.Picking = true
                    ElementButton:SetKeybind(nil, true)

                    local inputObject = UserInputService.InputBegan:Wait()
                    local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown

                    if isKeyCode and inputObject.KeyCode == Enum.KeyCode.Escape then
                        ElementButton:SetKeybind(nil)
                        ElementButton.Picking = false
                        return
                    end

                    ElementButton.KeyPressed = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
                    ElementButton:SetKeybind(ElementButton.KeyPressed)
                end)

                Midnight:AddConnection(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
                    if (input.KeyCode == ElementButton.Keybind or input.UserInputType == ElementButton.Keybind) and not ElementButton.Picking and not gameProcessedEvent then
                        ElementButton.TimesClicked += 1
                        Midnight:SafeCallback(options.Callback, ElementButton.TimesClicked)
                    end
                end))

                ElementButton:SetKeybind(ElementButton.Keybind)

                setmetatable(ElementButton, BaseComponents)
            end

            return ElementButton
        end

        function Tab:AddElementToggle(options: ElementToggleOptions)
            local ElementHolder: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                Parent = Elements
            })

            local ButtonFrame: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                FontFace = regularFont,
                Size = UDim2.new(1, 0, 0, 36),
                Text = options.Name or "Button",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ElementHolder
            })

            --// Keybind Button \\--
            local KeybindButton: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 0.95,
                FontFace = semiBoldFont,
                Position = UDim2.new(1, -28, 0, 8),
                Size = UDim2.fromOffset(20, 20),
                Text = "...",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = ElementHolder
            })

            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = KeybindButton
            })

            local Components = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.new(1, 0, 1, -36),
                Parent = ElementHolder
            })

            local ComponentsListLayout = Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Components
            })
            
            local Icon: ImageLabel = Create("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7072719531",
                ImageTransparency = 0.5,
                Position = UDim2.new(1, -4, 0, 8),
                Size = UDim2.fromOffset(20, 20),
                ZIndex = 2,
                Parent = ElementHolder
            })

            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8), 
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11),
                PaddingTop = UDim.new(0, 8),
                Parent = ButtonFrame
            })

            --// Element Toggle Table \\--
            local ElementToggle = {
                Container = Components,
                Hovering = false,
                KeyPressed = nil,
                Locked = false,
                Opened = false,
                Picking = false,
                State = false,

                Name = options.Name or "Toggle",
                Value = options.Value or false,
                
                Keybind = options.Keybind or nil,
                Mode = options.Mode or "Toggle",

                Type = "ElementToggle"
            }

            function ElementToggle:Set(newValue: boolean)
                local oldValue = ElementToggle.Value
                ElementToggle.Value = newValue

                ButtonFrame.BackgroundColor3 = ElementToggle.Value and Color3.fromRGB(35, 35, 35) or (ElementToggle.Hovering and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(25, 25, 25))
                ButtonFrame.TextTransparency = ElementToggle.Value and 0 or (ElementToggle.Hovering and 0.25 or 0.5)

                if ElementToggle.Value ~= oldValue then
                    Midnight:SafeCallback(options.Callback, ElementToggle.Value, oldValue)
                end
            end

            function ElementToggle:SetLocked(locked: boolean)
                ElementToggle.Locked = locked

                if ElementToggle.Hovering then
                    Icon.Position = ElementToggle.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                    Icon.Image = ElementToggle.Locked and "rbxassetid://7072718362" or "rbxassetid://7072719531"
                end
            end

            function ElementToggle:SetKeybind(keybind: Enum.KeyCode | Enum.UserInputType, picking)        
                ElementToggle.Keybind = keybind

                ElementToggle:UpdateKeybind(ElementToggle.Keybind, picking)
            end

            function ElementToggle:UpdateKeybind(keybind, picking)
                local keyText = picking and "..." or (keybind and (keyCodesName[keybind] or string.sub(keybind.Name, 1, 6)) or "None")

                local params = Instance.new("GetTextBoundsParams")
                params.Font = semiBoldFont
                params.Size = 14
                params.Text = keyText
                params.Width = Midnight.UISize - 24

                local size = TextService:GetTextBoundsAsync(params)

                KeybindButton.Size = UDim2.fromOffset(size.X + 12, 20)
                KeybindButton.Text = keyText
            end

            function ElementToggle:Toggle()
                ElementToggle.Opened = not ElementToggle.Opened

                ElementHolder.Size = ElementToggle.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
            end

            --// Element Toggle Connections \\--
            do
                if options.Flag then
                    Midnight.Flags[options.Flag] = ElementToggle
                end

                ComponentsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ElementHolder.Size = ElementToggle.Opened and UDim2.new(1, 0, 0, ComponentsListLayout.AbsoluteContentSize.Y + 36) or UDim2.new(1, 0, 0, 36)
                end)

                ButtonFrame.MouseEnter:Connect(function()
                    ElementToggle.Hovering = true
                    Icon.Position = ElementToggle.Locked and UDim2.new(1, -7, 0, 8) or UDim2.new(1, -4, 0, 8)
                    Icon.Image = ElementToggle.Locked and "rbxassetid://7072718362" or "rbxassetid://7072719531"
                    
                    if not ElementToggle.Value and not ElementToggle.Locked then
                        ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        ButtonFrame.TextTransparency = 0.25
                    end
                end)
    
                ButtonFrame.MouseLeave:Connect(function()
                    ElementToggle.Hovering = false
                    Icon.Image = "rbxassetid://7072719531"
                    Icon.Position = UDim2.new(1, -4, 0, 8)

                    if not ElementToggle.Value and not ElementToggle.Locked then
                        ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        ButtonFrame.TextTransparency = 0.5
                    end
                end)
    
                ButtonFrame.MouseButton1Click:Connect(function()
                    if ElementToggle.Locked then return end
                    ElementToggle:Set(not ElementToggle.Value)
                end)

                ButtonFrame.MouseButton2Click:Connect(function()
                    ElementToggle:Toggle()
                end)

                KeybindButton.MouseEnter:Connect(function()
                    KeybindButton.TextTransparency = 0.25
                end)

                KeybindButton.MouseLeave:Connect(function()
                    KeybindButton.TextTransparency = 0.5
                end)

                KeybindButton.MouseButton1Click:Connect(function()
                    if ElementToggle.Picking then return end
                    
                    ElementToggle.Picking = true
                    ElementToggle:SetKeybind(nil, true)

                    local inputObject = UserInputService.InputBegan:Wait()
                    local isKeyCode = inputObject.KeyCode ~= Enum.KeyCode.Unknown

                    if isKeyCode and inputObject.KeyCode == Enum.KeyCode.Escape then
                        ElementToggle:SetKeybind(nil)
                        ElementToggle.Picking = false
                        return
                    end

                    ElementToggle.KeyPressed = isKeyCode and inputObject.KeyCode or inputObject.UserInputType
                    ElementToggle:SetKeybind(ElementToggle.KeyPressed)
                end)

                Midnight:AddConnection(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
                    if not ElementToggle.Locked and (input.KeyCode == ElementToggle.Keybind or input.UserInputType == ElementToggle.Keybind) and not ElementToggle.Picking and not gameProcessedEvent then
                        if ElementToggle.Mode == "Hold" then
                            ElementToggle:Set(true) 
                        else
                            ElementToggle:Set(not ElementToggle.Value)
                        end
                    end
                end))

                Midnight:AddConnection(UserInputService.InputEnded:Connect(function(input: InputObject)
                    if not ElementToggle.Locked and (input.KeyCode == ElementToggle.Keybind or input.UserInputType == ElementToggle.Keybind) and not ElementToggle.Picking then
                        if ElementToggle.Mode == "Hold" then
                            ElementToggle:Set(false)
                        end
                    elseif (input.KeyCode == ElementToggle.KeyPressed or input.UserInputType == ElementToggle.KeyPressed) and ElementToggle.Picking then
                        ElementToggle.KeyPressed = nil
                        ElementToggle.Picking = false
                    end
                end))

                ElementToggle:Set(ElementToggle.Value)
                ElementToggle:SetKeybind(ElementToggle.Keybind)

                setmetatable(ElementToggle, BaseComponents)
            end

            return ElementToggle
        end

        --// Tab Connections \\--
        do
            MakeDraggable(Top, TabHolder)

            Elements.Size = UDim2.new(1, 0, 0, math.clamp(ElementsListLayout.AbsoluteContentSize.Y, 0, workspace.CurrentCamera.ViewportSize.Y / 1.6))

            ElementsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Elements.Size = UDim2.new(1, 0, 0, math.clamp(ElementsListLayout.AbsoluteContentSize.Y, 0, workspace.CurrentCamera.ViewportSize.Y / 1.6))
            end)
        
            TabButton.MouseEnter:Connect(function()
                Tab.Hovering = true
                if not Tab.Opened then
                    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    TabButtonText.TextTransparency = 0.25
                end
            end)
        
            TabButton.MouseLeave:Connect(function()
                Tab.Hovering = false
                if not Tab.Opened then
                    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    TabButtonText.TextTransparency = 0.5
                end
            end)
        
            TabButton.MouseButton1Click:Connect(function()
                task.spawn(Tab.Toggle)
            end)

            Tab:Toggle()
        end

        return Tab
    end

    function Window:BuildSettingsElement(tab: table)
        local UISection = tab:AddElementSection("UI Manager")
        local SaveSection = tab:AddElementSection("Save Manager")


        --// UI Section \\--
        Midnight.ToggleKeybind = UISection:AddKeyPicker({
            Name = "Toggle Keybind",
            Flag = "_ToggleKeybind",
            Keybind = Midnight.ToggleKeybind
        })

        UISection:AddSlider({
            Name = "Notify Volume",
            Flag = "_NotifyVolume",
            Min = 0,
            Max = 4,
            Increment = 0.5,
            Value = Midnight.NotifyVolume,
            Callback = function(value)
                Midnight.NotifyVolume = value
            end
        })

        UISection:AddButton({
            Name = "Unload",
            Callback = function()
                Midnight:Unload()
            end
        })

        

        --// Save Section \\--
        local configName = SaveSection:AddTextbox({
            Name = "Config Name"
        })

        local configList = SaveSection:AddDropdown({
            Name = "Configs List",
            Values = GetSavedConfigs()
        })

        SaveSection:AddDivider()

        SaveSection:AddButton({
            Name = "Create Config",
            Callback = function()
                local name = configName.Text
                if name:gsub(" ", "") == "" then return Midnight:Notify("Config Name can't be empty") end

                local success, error = SaveConfig(name)

                if not success then
                    return Midnight:Notify(string.format("Failed to create config: %s", name))
                end

                configList:SetValues(GetSavedConfigs())
                Midnight:Notify(string.format("Created config: %s", name))
            end
        })

        SaveSection:AddButton({
            Name = "Load Config",
            Callback = function()
                local name = configList.Value
                if not name then return Midnight:Notify("Select a config to load") end

                local success, error = LoadConfig(name)

                if not success then
                    return Midnight:Notify(string.format("Failed to load config: %s\nError: %s", name, error))
                end

                Midnight:Notify(string.format("Loaded config: %s", name))
            end
        })

        SaveSection:AddButton({
            Name = "Overwrite Config",
            DoubleClick = true,
            Callback = function()
                local name = configList.Value
                if not name then return Midnight:Notify("Select a config to overwrite") end

                local success, error = SaveConfig(name)

                if not success then
                    return Midnight:Notify(string.format("Failed to overwrite config: %s", name))
                end

                Midnight:Notify(string.format("Overwrote config: %s", name))
            end
        })

        SaveSection:AddButton({
            Name = "Set as Autoload",
            Callback = function()
                local name = configList.Value
                if not name then return Midnight:Notify("Select a config to autoload") end

                Midnight:SetAutoloadConfig(name)
                Midnight:Notify(string.format("Set %s to autoload", name))
            end
        })

        SaveSection:AddButton({
            Name = "Refresh List",
            Callback = function()
                configList:SetValues(GetSavedConfigs())
            end
        })
    end

    --// Window Connections \\--
    do
        if Midnight.Mobile then
            local MobileButton: TextButton = Create("TextButton", {
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                FontFace = regularFont,
                Position = UDim2.new(1, -7, 0, 7),
                Size = UDim2.fromOffset(120, 40),
                Text = "Toggle UI",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 28,
                Parent = UI
            })
        
            Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(60, 60, 60),
                Parent = MobileButton
            })
        
            MobileButton.MouseButton1Click:Connect(function()
                task.spawn(Midnight.Toggle)
            end)
        end

        Midnight:AddConnection(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
            if typeof(Midnight.ToggleKeybind) == "table" and Midnight.ToggleKeybind.Type == "KeyPicker" and input.KeyCode == Midnight.ToggleKeybind.Keybind and not Midnight.ToggleKeybind.Picking then
                task.spawn(Midnight.Toggle)
            elseif input.KeyCode == Midnight.ToggleKeybind then
                task.spawn(Midnight.Toggle)
            end
        end))

        MakeDraggable(Top, MainWindow)
    end

    return Window
end

function Midnight:Notify(text: string, duration: number, soundId: number)
    duration = duration or 5
    soundId = soundId or Midnight.NotifySound

    local params = Instance.new("GetTextBoundsParams")
    params.Font = regularFont
    params.Text = text
    params.Size = 24
    params.Width = (workspace.CurrentCamera.ViewportSize.X / 4) - 12

    local textSize = TextService:GetTextBoundsAsync(params)

    local NotificationHolder = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(textSize.X + 18, textSize.Y + 18),
        Parent = Notifications
    })

    local NotificationText: TextLabel = Create("TextLabel", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0.25,
        FontFace = regularFont,
        Position = UDim2.new(1, 6, 0, 0),
        Size = UDim2.fromScale(1, 1),
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 24,
        TextWrapped = true,
        Parent = NotificationHolder
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = NotificationText
    })

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        Parent = NotificationText
    })

    Create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.fromRGB(90, 90, 90),
        Parent = NotificationText
    })
    
    if soundId then
        Create("Sound", {
            SoundId = "rbxassetid://" .. soundId,
            Volume = Midnight.NotifyVolume,
            PlayOnRemove = true,
            Parent = CoreGui
        }):Destroy()
    end

    NotificationText:TweenPosition(UDim2.fromScale(0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.3)

    task.delay(duration, function()
        NotificationText:TweenPosition(UDim2.new(1, 6, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.3)
        task.wait(0.3)
        NotificationHolder:Destroy()
    end)
end

function Midnight:Save(name)
    SaveConfig(name)
end

function Midnight:LoadAutoloadConfig()
    if not CheckSaveFolder() then return end

    local settingsData = {}
    if isfile(Midnight.SaveFolder .. "/settings.json") then
        settingsData = HttpService:JSONDecode(readfile(Midnight.SaveFolder .. "/settings.json"))
    end
    
    if settingsData["Autoload"] then
        LoadConfig(settingsData["Autoload"])
    end
end

function Midnight:SetAutoloadConfig(name)
    if not CheckSaveFolder() then return end
    
    local data = {
        ["Autoload"] = name
    }

    writefile(Midnight.SaveFolder .. "/settings.json", tostring(HttpService:JSONEncode(data)))
end

local ModalElement = Create("TextButton", {
    BackgroundTransparency = 1,
    Modal = true,
    Size = UDim2.fromScale(1, 1),
    Text = "",
    Visible = false,
    ZIndex = 0,
    Parent = UI
})

function Midnight:Toggle()
    Midnight.Opened = not Midnight.Opened

    ModalElement.Visible = Midnight.Opened
    Windows.Visible = Midnight.Opened
    Midnight.Blur.Enabled = Midnight.Opened

    if Midnight.Opened and not Midnight.Studio then  
        RunService:BindToRenderStep("OverrideCursor", Enum.RenderPriority.Camera.Value, function()
            UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow

            if not (Midnight.Opened and UI.Parent) then
                UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
                RunService:UnbindFromRenderStep("OverrideCursor")
            end
        end)
    end
end

function Midnight:Unload()
    for _, connection in pairs(Midnight.Connections) do
        connection:Disconnect()
    end

    if Midnight.Blur then Midnight.Blur:Destroy() end
    UI:Destroy()

    if Midnight.OnUnload then
        Midnight.OnUnload()
    end
end


return Midnight, Midnight.Flags
