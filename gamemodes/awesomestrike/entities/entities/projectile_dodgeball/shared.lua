ENT.Type = "anim"

function ENT:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_DODGEBALL, nil
end
