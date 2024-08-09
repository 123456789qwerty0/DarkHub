pcall(function()
    local lighting = game:GetService("Lighting")
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
    lighting.Brightness = 1
    lighting.FogEnd = 1e10
    for i, v in pairs(lighting:GetDescendants()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
    lighting.Changed:Connect(function()
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 1
        lighting.FogEnd = 1e10
    end)
    spawn(function()
        local character = game:GetService("Players").LocalPlayer.Character
        while wait() do
            repeat wait() until character ~= nil
            if not character.HumanoidRootPart:FindFirstChildWhichIsA("PointLight") then
                local headlight = Instance.new("PointLight", character.HumanoidRootPart)
                headlight.Brightness = 1
                headlight.Range = 60
            end
        end
    end)
end)

for i = 1, 1000 do
    ---====== Define spawner ======---

    local Spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/Scripts/Games/Doors/EntitySpawner/EntitySpawner.lua"))()

    ---====== Create entity ======---

    local entity = Spawner.createEntity({
        CustomName = "I'M LSPLASH!",
        Model = "rbxassetid://12905452057", -- Your entity's model url here ("rbxassetid://1234567890" or GitHub raw url)
        Speed = 10,
        MoveDelay = 2,
        HeightOffset = 0,
        CanKill = false,
        KillRange = 50,
        SpawnInFront = false,
        ShatterLights = true,
        FlickerLights = {
            Enabled = true,
            Duration = 1
        },
        Cycles = {
            Min = 1,
            Max = 1,
            Delay = 0
        },
        CamShake = {
            Enabled = true,
            Values = {1.5, 20, 0.1, 1},
            Range = 100
        },
        ResistCrucifix = false,
        BreakCrucifix = true,
        DeathMessage = {"how did you die :P ", "bald kreek could beat you", "anyways 92.28.211.234", ":D"},
        IsCuriousLight = true
    })

    ---====== Debug ======---

    entity.Debug.OnEntitySpawned = function()
        print("Entity has spawned")
    end

    entity.Debug.OnEntityDespawned = function()
        print("Entity has despawned")
    end

    entity.Debug.OnEntityStartMoving = function()
        print("Entity started moving")
    end

    entity.Debug.OnEntityFinishedRebound = function()
        print("Entity finished rebound")
    end

    entity.Debug.OnEntityEnteredRoom = function(room)
        print("Entity entered room:", room)
    end

    entity.Debug.OnLookAtEntity = function()
        print("Player looking at entity")
    end

    entity.Debug.OnDeath = function()
        print("Player has died")
    end

    Spawner.runEntity(entity)
end

-- Define the music variables
local soundId = "rbxassetid://6385111188"

-- Function to create and play the music
function playMusic()
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = game.Workspace
    sound:Play()
end

-- Function to create the GUI
function createGui()
    local musicGui = Instance.new("ScreenGui")
    musicGui.Parent = game.Players.LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.Parent = musicGui

    local playButton = Instance.new("TextButton")
    playButton.Size = UDim2.new(0, 100, 0, 50)
    playButton.Position = UDim2.new(0.5, -50, 0.5, -25)
    playButton.Text = "Play Music"
    playButton.Parent = frame
    playButton.MouseButton1Click:Connect(playMusic)
end

createGui()
