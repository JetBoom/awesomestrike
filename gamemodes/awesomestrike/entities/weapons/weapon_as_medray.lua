AddCSLuaFile()

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.Help = {"Hold left click: Healing Beam"}


	SWEP.VElements = {
		["medkit"] = { type = "Model", model = "models/Items/HealthKit.mdl", bone = "Base", rel = "", pos = Vector(0, 0, -8.606), angle = Angle(180, 180, 45), size = Vector(0.247, 0.247, 0.247), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["medkit"] = { type = "Model", model = "models/Items/HealthKit.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.189, -0.806, -4.506), angle = Angle(-161.288, 99.775, -60.269), size = Vector(0.247, 0.247, 0.247), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Slot = 0 --SWEP.Slot = 2

SWEP.PrintName = "Heal Ray"

SWEP.HoldType = "shotgun"
SWEP.SprintHoldType = "passive"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"

SWEP.Primary.ClipSize = 50
SWEP.Primary.Automatic = false

SWEP.WalkSpeed = SPEED_SLOW

SWEP.Cone = 1
SWEP.ConeVariance = 0

function SWEP:Reload()
	if not IsValid(self.Owner.status_medrayreload) and not self.Owner:KeyDown(IN_ATTACK) and self:Clip1() < self.Primary.ClipSize then
		self.Owner:GiveStatus("medrayreload")
		self:SendWeaponAnim(ACT_VM_RELOAD)
	end
end

function GetClosetPoint(A, B, P, segmentClamp)
	local AP = P - A
	local AB = B - A
	local ab2 = AB.x * AB.x + AB.y * AB.y
	local ap_ab = AP.x * AB.x + AP.y * AB.y;
	local t = ap_ab / ab2
	if (segmentClamp) then
		if t < 0 then
			t = 0
		elseif t > 1 then
			t = 1
		end
	end

	return A + AB * t
end

if SERVER then
	function SWEP:Think()
		local owner = self.Owner
		if self:IsReloading() then
			if owner.MedRay then
				owner:RemoveStatus("medray", false, true)
			end

			if not owner.MedRayReload then
				self:SetReloadEnd(0)
			end
		else
			if owner.MedRay then
				if owner:KeyDown(IN_ATTACK) and 0 < self:Clip1() and not owner:IsFrozen() then
					self:SetShootingEnd(CurTime() + 0.4)
					if self:CanPrimaryAttack() then
						self:SetNextPrimaryFire(CurTime() + 0.16)
						self:TakePrimaryAmmo(1)

						owner:LagCompensation(true)
						local ent = owner:TraceHull(1024, MASK_SHOT, 16).Entity
						if ent and ent:IsPlayer() and ent:Alive() and ent:Team() == owner:Team() then
							gamemode.Call("PlayerHeal", owner, ent, 1)
						end
						owner:LagCompensation(false)
					end
				elseif owner.MedRay:IsValid() then
					owner.MedRay:Remove()
				end
			end		
		end

		self:NextThink(CurTime())
		return true
	end

	function SWEP:PrimaryAttack()
		if self:CanPrimaryAttack() then
			local ct = CurTime()

			self:SetNextPrimaryFire(ct + self.Primary.Delay)
			self:SetNextSecondaryFire(ct + self.Primary.Delay)

			self:EmitSound("items/medshot4.wav")

			self.Owner:InterruptSpecialMoves()

			self:SetShootingEnd(ct + 0.5)

			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:DoAttackEvent()

			self.Owner:GiveStatus("medray")
		end
	end
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 and not self.Owner:KeyDown(IN_RELOAD) then
		self:EmitSound("items/medshotno1.wav")
		self:SetNextPrimaryFire(CurTime() + 0.75)
		return false
	end

	return self.BaseClass.CanPrimaryAttack(self)
end

function SWEP:IsIdle()
	return not self.Owner:KeyDown(IN_RELOAD) and not self.Owner:KeyDown(IN_ATTACK) and self.BaseClass.IsIdle(self)
end

if CLIENT then
	function SWEP:PrimaryAttack()
		if self:CanPrimaryAttack() then
			local ct = CurTime()

			self:SetNextPrimaryFire(ct + self.Primary.Delay)
			self:SetNextSecondaryFire(ct + self.Primary.Delay)

			self:EmitSound("items/medshot4.wav")

			self:SetShootingEnd(ct + 0.5)

			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:DoAttackEvent()
		end
	end
	
	function SWEP:Think()
		local owner = self.Owner
		if owner.MedRay and owner:KeyDown(IN_ATTACK) and 0 < self:Clip1() and not owner.Stunned and not owner:IsKnockedDown() then
			self:SetShootingEnd(CurTime() + 0.4)
			if self:CanPrimaryAttack() then
				self:SetNextPrimaryFire(CurTime() + 0.1)
				self:TakePrimaryAmmo(1)
			end
		end

		self:NextThink(CurTime())
		return true
	end
end
