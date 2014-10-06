ENT.Type = "anim"

ENT.m_IsProjectile = true

function ENT:GetKillAction(pl, attacker, dmginfo)
	return (attacker:GetState() == STATE_AWESOMELAUNCHERGUIDE or attacker:GetState() == STATE_AWESOMELAUNCHEREND) and KILLACTION_AWESOMELAUNCHERGUIDED or KILLACTION_AWESOMELAUNCHER, nil
end
