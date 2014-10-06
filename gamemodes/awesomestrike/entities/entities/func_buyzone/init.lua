ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:KeyValue(key, value)
	if string.lower(key) == "teamnum" then
		if value == "2" then self.TeamID = TEAM_T
		elseif value == "3" then self.TeamID = TEAM_CT
		else self.TeamID = nil end
	end
end

function ENT:AcceptInput(name, activator, caller, arg)
	if string.lower(name) == "setteam" then
		if arg == "2" then self.TeamID = TEAM_T
		elseif arg == "3" then self.TeamID = TEAM_CT
		else self.TeamID = nil end
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and (not self.TeamID or ent:Team() == self.TeamID) then
		ent.CanBuy = self
		ent:SendLua("CanBuy="..self:EntIndex())
	end
end

function ENT:EndTouch(ent)
	if ent.CanBuy == self then
		ent.CanBuy = nil
		ent:SendLua("CanBuy=nil")
	end
end

function ENT:Touch(ent)
end
