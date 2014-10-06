AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.BaseModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	OnlyBulletCollide[self] = SOLID_VPHYSICS
end

function ENT:OnRemove()
	OnlyBulletCollide[self] = nil
end

function ENT:OnHitWithBullet(bullet, tr, prehit)
	local owner = self:GetOwner()
	if owner:IsValid() and CurTime() >= owner:GetStateStart() + STATES[STATE_FORCESHIELD].PrepTime / 3 then
		local ownerteam = owner:Team()
		local bulletowner = bullet:GetOwner()
		if bulletowner:IsValid() then
			local bulletteam = bulletowner:Team()
			if bulletteam ~= ownerteam and tr.HitNormal:Dot(owner:SyncAngles():Forward()) > 0 then
				bullet.ForceShielded = true

				bullet:SetOwner(owner)
				bullet:StoreAttackerState(owner)
				if bulletowner:GetStateEntity() == bullet then
					bulletowner:SetStateEntity(NULL)
				end
				bullet.BulletFilter = owner:GetAttackFilter()
				local col = team.GetColor(owner:Team()) or color_white
				bullet:SetColor(col)

				owner:SetEnergy(math.max(0, owner:GetEnergy() - (bullet.Damage or 1) / 3), nil, true)

				local phys = bullet:GetPhysicsObject()
				if phys:IsValid() then
					sound.Play("weapons/fx/rics/ric"..math.random(1, 5)..".wav", tr.HitPos, 70, math.random(100, 110))
					bullet.LastPosition = tr.HitPos + tr.HitNormal * 0.5
					if not prehit then phys:SetPos(bullet.LastPosition) end
					phys:SetVelocityInstantaneous((2 * tr.HitNormal:Dot(tr.Normal * -1) * tr.HitNormal + tr.Normal) * bullet.Speed)
				end
			end
		end
	end

	return 1
end
