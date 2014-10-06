-- Very experimental. If lagcompensation is called outside of a SWEP then the game freezes or crashes.

OnlyBulletCollide = {}

local bulletmins = Vector(-0.75, -0.75, -0.75)
local bulletmaxs = Vector(0.75, 0.75, 0.75)
function BulletTrace(startposition, endposition, filter)
	for ent, col in pairs(OnlyBulletCollide) do ent:SetSolid(col) end
	local tr = util.TraceHull({start = startposition, endpos = endposition, mask = MASK_SHOT, filter = filter, mins = bulletmins, maxs = bulletmaxs})
	for ent in pairs(OnlyBulletCollide) do ent:SetSolid(SOLID_NONE) end

	return tr
end

function CreateBullet(pos, dir, attacker, inflictor, damage, speed, class, fromweapon, nocompensation)
	--[[if fromweapon then
		return CreatePredictedBullet(pos, dir, attacker, inflictor, damage, speed, CurTime(), fromweapon)
	end]]

	-- Give players ping compensation for physical bullets.
	local vel = dir * speed
	local pingmul = fromweapon and not nocompensation and math.min(attacker:Ping(), 250) / 1100 or 0
	local predictedstartpos = fromweapon and (pos + pingmul * vel) or pos

	-- If we would hit something real close, tell the created bullet to hit that entity right after it's created.
	local prehit
	if fromweapon then attacker:LagCompensation(true) end
	local tr = BulletTrace(pos, pos + math.max(0.04, pingmul) * vel, attacker and attacker:GetAttackFilter())
	if tr.Hit then
		prehit = tr
	end
	if fromweapon then attacker:LagCompensation(false) end

	if CLIENT then
		if prehit then
			(inflictor or attacker):FakeBullet(pos, dir)
		end
		return
	end

	local bullet = ents.Create(class or "projectile_asbullet")
	if bullet:IsValid() then
		bullet.LastPosition = pos
		if speed then
			bullet.Speed = bullet.Speed or speed
		end
		bullet:SetPos(predictedstartpos)
		bullet:SetAngles(dir:Angle())
		if attacker and attacker:IsValid() then
			bullet:SetOwner(attacker)
			if attacker:IsPlayer() then
				bullet:StoreAttackerState(attacker)
				bullet:SetColor(team.GetColor(attacker:Team()) or color_white)
			end
		end

		bullet.Inflictor = inflictor or attacker or NULL
		bullet.Damage = damage

		bullet:SetVelocity(vel)

		bullet:Spawn()

		local phys = bullet:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(vel)
		end

		if prehit then
			bullet:Hit(prehit, true)
			bullet:NextThink(CurTime())
		end
	end

	return bullet
end
