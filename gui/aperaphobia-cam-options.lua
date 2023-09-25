local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/miroeramaa/TurtleLib/main/TurtleUiLib.lua"))()
local window1 = library:Window("darkhub aperaphobia camera options")
window1:Toggle("exit esp", false, function(State1)
    loadstring(game:HttpGet("https://gist.githubusercontent.com/123456789qwerty0/9787b7d794db3e03e1cef169697fe858/raw/b90becdadcd5a217b805bf48cae8538c21ee54e4/aperaphobiaesp.lua"))()
end)

window1:Toggle("fullbright", false, function(State1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/-/main/-"))()
end)

window1:Toggle("more stuff", false, function(State1)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/123456789qwerty0/camera-options/main/main.lua"))()
end)
