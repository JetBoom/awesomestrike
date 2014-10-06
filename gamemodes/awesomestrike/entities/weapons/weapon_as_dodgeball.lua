AddCSLuaFile()

if CLIENT then
	SWEP.DrawAmmo = false

	SWEP.Cone = 0.5
	SWEP.ConeVariance = 0

	SWEP.ForceThirdPerson = true
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_phx/misc/soccerball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.205, 10.675, 0), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255)},
		["deco"] = { type = "Sprite", sprite = "sprites/glow", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 0), size = { x = 32, y = 32 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = false, vertexcolor = false, ignorez = false}
	}

	GAMEMODE:SetupCoolDownWeapon(SWEP)
end

SWEP.Slot = 0

SWEP.PrintName = "Dodge Ball"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel = Model("models/props_phx/misc/soccerball.mdl")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 10
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.SprintHoldType = "grenade"
SWEP.HoldType = "grenade"

SWEP.CoolDown = 30

SWEP.GrenadeClass = "projectile_dodgeball"

function SWEP:Think()
	if self:GetFinishTime() ~= 0 then
		if CurTime() >= self:GetFinishTime() then
			self:SetThrowTime(0)
			self:SetFinishTime(0)
			if SERVER then
				self.Owner:SwitchToBestWeapon()
			end
		end

		self:NextThink(CurTime())
		return true
	elseif self:GetThrowTime() ~= 0 then
		if CurTime() >= self:GetThrowTime() then
			self:Throw()
		end

		self:NextThink(CurTime())
		return true
	end
end

function SWEP:Throw()
	self:SetThrowTime(0)

	local owner = self.Owner

	owner:InterruptSpecialMoves()

	self:EmitSound("weapons/slam/throw.wav")

	self:SendWeaponAnim(ACT_VM_THROW)
	self:SetFinishTime(CurTime() + 0.75)
	self:ResetCoolDown()

	if CLIENT then return end

	local ent = ents.Create(self.GrenadeClass)
	if ent:IsValid() then
		ent:SetPos(owner:GetShootPos())
		ent:SetAngles(owner:EyeAngles())
		ent:SetOwner(owner)
		ent.Thrower = owner
		ent.m_Team = owner:Team()
		ent:SetColor(team.GetColor(ent.m_Team) or color_white)
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(owner:GetAimVector() * 1800)
			phys:AddAngleVelocity(Vector(0, 1800, 0))
		end
		ent:SetPhysicsAttacker(owner)
	end
end

function SWEP:OnKnockedDown(oldstate)
	self:SetNextPrimaryAttack(0)
	self:SetThrowTime(0)
end
SWEP.OnFlinched = SWEP.OnKnockedDown

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self.Owner:DoAttackEvent()
	self:SetThrowTime(CurTime() + 0.3)

	self:NextThink(CurTime())
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return self:GetThrowTime() == 0 and self:GetFinishTime() == 0 and not self.Owner:GetStateTable().CantUseWeapons and CurTime() >= self:GetCoolDown()
end

function SWEP:IsIdle()
	return self:GetThrowTime() == 0 and self:GetFinishTime() == 0
end

function SWEP:OnHolster()
	if self:IsIdle() then
		self:SetThrowTime(0)
		return true
	end

	return false
end

function SWEP:SetThrowTime(time)
	self:SetDTFloat(2, time)
end

function SWEP:GetThrowTime()
	return self:GetDTFloat(2)
end

function SWEP:SetFinishTime(time)
	self:SetDTFloat(3, time)
end

function SWEP:GetFinishTime()
	return self:GetDTFloat(3)
end
