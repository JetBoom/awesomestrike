ENT.Type = "anim"

function ENT:GetTeam()
	return self:GetDTInt(0)
end

function ENT:SetTeam(teamid)
	self:SetDTInt(0, teamid)
end

function ENT:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_BEEHIVE, nil
end