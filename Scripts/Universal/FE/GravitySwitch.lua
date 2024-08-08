if _G.GravitySwitchStarted == nil then
	_G.GravitySwitchStarted = true
	
	local mouse = game:GetService("Players").LocalPlayer:GetMouse()

	repeat wait() until mouse

	mouse.KeyDown:connect(function(key)
		if key:lower() == "e" then
			if workspace.Gravity > 0 then
				workspace.Gravity = 0
				game.StarterGui:SetCore("SendNotification", {Title="Gravity Switch"; Text="Gravity set to 0."; Duration=1;})
			else 
				workspace.Gravity = 196.2
				game.StarterGui:SetCore("SendNotification", {Title="Gravity Switch"; Text="Gravity set to normal."; Duration=1;})
			end
		end
	end)
end

game.StarterGui:SetCore("SendNotification", {Title="Gravity Switch"; Text="Press 'e' to toggle gravity."; Duration=5;})
