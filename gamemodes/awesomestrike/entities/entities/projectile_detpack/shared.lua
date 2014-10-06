ENT.Type = "anim"

ENT.m_IsProjectile = true

function ENT:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_DETONATED, nil
end

function ENT:GetTeam() return self:GetDTInt(0) end
ENT.Team = ENT.GetTeam
function ENT:SetTeam(teamid) self:SetDTInt(0, teamid) end
