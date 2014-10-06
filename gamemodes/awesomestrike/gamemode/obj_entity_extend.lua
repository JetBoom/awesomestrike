local meta = FindMetaTable("Entity")
if not meta then return end

if CLIENT then
	function meta:SetModelScaleVector(vec)
		if self:GetBoneCount() > 1 then
			local scale
			if type(vec) == "number" then
				scale = vec
			else
				scale = math.min(vec.x, vec.y, vec.z)
			end
			self._ModelScale = Vector(scale, scale, scale)
			self:SetModelScale(scale, 0)
		else
			if type(vec) == "number" then
				vec = Vector(vec, vec, vec)
			end

			self._ModelScale = vec
			local m = Matrix()
			m:Scale(vec)
			self:EnableMatrix("RenderMultiply", m)
		end
	end
end

function meta:GetBonePositionMatrixed(index)
	local matrix = self:GetBoneMatrix(index)
	if matrix then
		return matrix:GetTranslation(), matrix:GetAngles()
	end

	return self:GetPos(), self:GetAngles()
end

function meta:TakeSpecialDamage(damage, damagetype, attacker, inflictor, hitpos)
	attacker = attacker or self
	if not attacker:IsValid() then attacker = self end
	inflictor = inflictor or attacker
	if not inflictor:IsValid() then inflictor = attacker end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(damage)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(inflictor)
	dmginfo:SetDamagePosition(hitpos or self:NearestPoint(inflictor:NearestPoint(self:LocalToWorld(self:OBBCenter()))))
	dmginfo:SetDamageType(damagetype)
	self:TakeDamageInfo(dmginfo)

	return dmginfo
end

function meta:Flinch()
end

function meta:IsValidSpectatorTarget()
	return not self:IsPlayer() or self:Alive() and self:GetObserverMode() == OBS_MODE_NONE
end

function meta:IsProjectile()
	return self:GetCollisionGroup() == COLLISION_GROUP_PROJECTILE or self.m_IsProjectile
end

function meta:StoreAttackerState(attacker)
	self._attackerstate = attacker:GetState()
end

function meta:ThrowFromPosition(pos, force, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			phys:ApplyForceOffset(force * 50 * (nearest - pos):GetNormalized(), nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() and self:GetState() ~= STATE_KNOCKEDDOWN and 256 <= math.abs(force) then
			self:KnockDown()
		end
		self:SetVelocity(force * (self:LocalToWorld(self:OBBCenter()) - pos):GetNormalized())

		return true
	end
end

function meta:ThrowFromPositionSetZ(pos, force, zmul, noknockdown)
	if force == 0 or self:IsProjectile() or self.NoThrowFromPosition then return false end
	zmul = zmul or 0.7

	if self:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			local nearest = self:NearestPoint(pos)
			local dir = nearest - pos
			dir.z = 0
			dir:Normalize()
			dir.z = zmul
			phys:ApplyForceOffset(force * 50 * dir, nearest)
		end

		return true
	elseif self:GetMoveType() >= MOVETYPE_WALK and self:GetMoveType() < MOVETYPE_PUSH then
		self:SetGroundEntity(NULL)
		if SERVER and not noknockdown and self:IsPlayer() and self:GetState() ~= STATE_KNOCKEDDOWN and 256 <= math.max(math.abs(force) * math.abs(zmul), math.abs(force)) then
			self:KnockDown()
		end

		local dir = self:LocalToWorld(self:OBBCenter()) - pos
		dir.z = 0
		dir:Normalize()
		dir.z = zmul
		self:SetVelocity(force * dir)

		return true
	end
end

local nodamage = {damage = false, effects = true}
local function BulletCallback(attacker, tr, dmginfo) return nodamage end
local fakebullet = {Num = 1, Tracer = 0, Force = 0, Damage = 0, Spread = Vector(0, 0, 0), Callback = BulletCallback}
function meta:FakeBullet(src, dir)
	fakebullet.Src = src
	fakebullet.Dir = dir
	self:FireBullets(fakebullet)
end
