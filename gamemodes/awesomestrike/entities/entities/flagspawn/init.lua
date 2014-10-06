ENT.Type = "point"

function ENT:Initialize()
end

function ENT:KeyValue(key, value)
	if string.lower(key) == "team" then
		if value == "1" then
			self.BlueTeam = true
		elseif value == "3" then
			self.YellowTeam = true
		elseif value == "4" then
			self.GreenTeam = true
		elseif value == "2" then
			self.RedTeam = true
		end
	end
end
