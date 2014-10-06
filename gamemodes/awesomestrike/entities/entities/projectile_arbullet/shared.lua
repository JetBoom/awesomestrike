ENT.Type = "anim"

ENT.Base = "projectile_asbullet"

function ENT:GetKillAction(pl, attacker, dmginfo)
	return (attacker:GetState() == STATE_AWESOMERIFLEGUIDE or attacker:GetState() == STATE_AWESOMERIFLEEND) and KILLACTION_AWESOMERIFLEGUIDED or KILLACTION_AWESOMERIFLE, nil
end
