AddCSLuaFile()

if CLIENT then
	function SWEP:GetViewModelPosition(pos, ang)
		local power = math.Clamp(math.min((self:GetShootingEnd() - CurTime()) * 0.5, (CurTime() - self.LastShoot) * 4), 0, 1)
		if power > 0 then
			power = CosineInterpolation(0, 1, power)
			pos = pos + power * -8 * ang:Up() + power * -8 * ang:Forward()
			ang:RotateAroundAxis(ang:Right(), power * 45)
		end

		return self.BaseClass.GetViewModelPosition(self, pos, ang)
	end

	SWEP.VElements = {
		["deco1+"] = { type = "Model", model = "models/props_c17/utilityconducter001.mdl", bone = "v_weapon.xm1014_Parent", rel = "", pos = Vector(-0.75, 3.144, 3.674), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1++"] = { type = "Model", model = "models/props_c17/utilityconnecter006b.mdl", bone = "v_weapon.xm1014_Parent", rel = "deco1+", pos = Vector(0.669, 0.212, 17.437), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1++++"] = { type = "Model", model = "models/props_combine/combine_mine01.mdl", bone = "v_weapon.xm1014_Parent", rel = "deco1+", pos = Vector(0.5, -0.181, -2.938), angle = Angle(90, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1+++"] = { type = "Model", model = "models/props_combine/combine_mine01.mdl", bone = "v_weapon.xm1014_Parent", rel = "deco1+", pos = Vector(0.5, -0.181, -2.938), angle = Angle(90, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1"] = { type = "Model", model = "models/props_c17/Handrail04_DoubleRise.mdl", bone = "v_weapon.xm1014_Parent", rel = "deco1+", pos = Vector(0.649, 1.169, 5.298), angle = Angle(0, 0, 55), size = Vector(0.075, 0.075, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["deco1++++"] = { type = "Model", model = "models/props_combine/combine_mine01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "deco1+", pos = Vector(0.5, -0.181, -2.938), angle = Angle(90, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1++"] = { type = "Model", model = "models/props_c17/utilityconnecter006b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "deco1+", pos = Vector(0.669, 0.212, 17.437), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1"] = { type = "Model", model = "models/props_c17/Handrail04_DoubleRise.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "deco1+", pos = Vector(0.649, 1.169, 5.298), angle = Angle(0, 0, 55), size = Vector(0.075, 0.075, 0.075), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1+++"] = { type = "Model", model = "models/props_combine/combine_mine01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "deco1+", pos = Vector(0.5, -0.181, -2.938), angle = Angle(90, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1+"] = { type = "Model", model = "models/props_c17/utilityconducter001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15.505, 0.617, -4.007), angle = Angle(168.731, -89.269, -91.913), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Slot = 0

SWEP.PrintName = "Rail Gun"

SWEP.HoldType = "ar2"
SWEP.SprintHoldType = "passive"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"

SWEP.Primary.Sound = false
SWEP.Primary.Damage = 51
SWEP.Primary.Delay = 2
SWEP.Primary.BusyTime = 0.8
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true
SWEP.Secondary.Automatic = false

SWEP.Cone = 0.01

SWEP.WalkSpeed = SPEED_SLOW

function SWEP:CanReload()
	return self.Owner:GetState() ~= STATE_RAILGUNCHARGE
end

function SWEP:FireRail()
	local owner = self.Owner

	local charge = owner:CallStateFunction("GetRailGunCharge") or 0

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetShootingEnd(CurTime() + self.Primary.BusyTime * (0.5 + charge * 0.5))

	if owner:GetState() == STATE_RAILGUNCHARGE then
		owner:EndState()
	end

	if self.Primary.Sound then
		self:EmitSound(self.Primary.Sound)
	end
	self:SendWeaponAnimation()
	self.Owner:DoAttackEvent()
	if self.MuzzleFlashEffect then
		local effectdata = EffectData()
			effectdata:SetEntity(self)
			effectdata:SetOrigin(self:GetPos())
		util.Effect(self.MuzzleFlashEffect, effectdata)
	end

	self.LastShoot = CurTime()

	owner:LagCompensation(true)

	local worldtrace
	local todamage = {}
	for _, tr in pairs(owner:PenetratingTraceLine(10240, MASK_SHOT, owner:GetBulletAttackFilter(self))) do
		if tr.HitWorld or not tr.Hit then
			worldtrace = tr
		else
			local ent = tr.Entity
			if IsValid(ent) then
				if SERVER and ent:GetClass() == "func_breakable_surf" then
					ent:Fire("break", "", 0)
				else
					if charge == 1 then
						ent:ThrowFromPositionSetZ(owner:GetPos(), charge * 512)
					else
						ent:ThrowFromPositionSetZ(owner:GetPos(), charge * 256)
					end
					ent:TakeSpecialDamage(self.Primary.Damage * 0.25 + self.Primary.Damage * charge * 0.75, DMG_SHOCK, owner, self, tr.HitPos)
				end
			end
		end
	end

	owner:ViewPunch(Angle(-30, math.Rand(-5, 5), math.Rand(-5, 5)) * (0.25 + charge * 0.75))

	if worldtrace and IsFirstTimePredicted() then
		local effectdata = EffectData()
			effectdata:SetOrigin(worldtrace.HitPos)
			effectdata:SetStart(owner:GetShootPos())
			effectdata:SetEntity(owner)
			effectdata:SetMagnitude(charge)
			effectdata:SetScale(owner:Team())
		util.Effect("railgunhit", effectdata)
		self:EmitSound("npc/strider/fire.wav", 75 + charge * 10, 200 - charge * 100)
	end

	owner:LagCompensation(false)
end

function SWEP:PrimaryAttack()
	if self.Owner:GetState() == STATE_RAILGUNCHARGE then
		self:FireRail()
		return
	end

	if self:CanPrimaryAttack() then
		self:FireRail()
	end
end

function SWEP:Think()
end

function SWEP:SecondaryAttack()
	if self.Owner:GetState() == STATE_RAILGUNCHARGE then
		self.Owner:EndState()
	elseif self:CanPrimaryAttack(true) and self.Owner:IsIdle() then
		self.Owner:SetState(STATE_RAILGUNCHARGE)
	end
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_RAILGUN, nil
end
