ENT.Type = "anim"

ENT.Base = "projectile_asbullet"

ENT.BulletModel = "models/seagull.mdl"

function ENT:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_DESERTEAGLE, nil
end
