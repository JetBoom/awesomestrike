hook.Add("InitPostEntity", "loading", function()
	local hostages = ents.FindByClass("hostage_entity")
	if hostages[1] then
		hostages[1]:SetPos(Vector(846, 782, -95))
	end
	if hostages[2] then
		hostages[2]:SetPos(Vector(815, 370, -95))
	end
end)
