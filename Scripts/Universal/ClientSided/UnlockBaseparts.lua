function Traverse(instance)
	for i,v in pairs (instance:GetChildren()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
		if #v:GetChildren() > 0 then
			Traverse(v)
		end
	end
end

Traverse(workspace)
