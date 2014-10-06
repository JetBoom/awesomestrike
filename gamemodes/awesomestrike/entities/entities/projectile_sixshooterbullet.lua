AddCSLuaFile()

ENT.Type = "anim"

ENT.Base = "projectile_asbullet"

function ENT:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_SIXSHOOTER, nil
end

if not SERVER then return end

function ENT:PostDoDamage(hitent, dmginfo, tr, prehit)
	hitent._SixShooterDamage = math.max(hitent._SixShooterDamage or 0, CurTime()) + 1
	local base = ((hitent._SixShooterDamage - CurTime()) - 1)
	if base > 0 then
		hitent:ThrowFromPositionSetZ(tr.StartPos, base * 225)
	end
end
