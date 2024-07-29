local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/UiLibraries/Wally/Lib.lua')))()
--wally's ui remade (archived by the darkhub team)
local w = library:CreateWindow("ESP") -- Creates the window

local b = w:CreateFolder("ESP") -- Creates the folder(U will put here your buttons,etc)

b:Button("ViewTracer", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/ViewTracer/Main.lua'))()
end)
-- Button to load the Unnamed ESP script
b:Button("Unnamed ESP", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/Unnamed/Main.lua'))()
end)

-- Button to load the Skeleton script
b:Button("Skeleton", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/Skeleton/Main.lua'))()
end)

-- Button to load the Sense script
b:Button("Sense", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/Sense/Loader.lua'))()
end)

-- Button to load the Healthbars script
b:Button("Healthbars", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/HealthBars/Healthbars.lua'))()
end)


b:Button("Seere", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/Seere/Seere.lua",true))()
end)

b:Button("sakpot.lua", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/sakpot.lua/Main.lua",true))()
end)

b:Button("UESP", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/DarkHub/main/gui/Chams/UESP/Loader.lua",true))()
end)
