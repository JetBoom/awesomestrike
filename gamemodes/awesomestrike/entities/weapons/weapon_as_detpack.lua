AddCSLuaFile()

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = true

	SWEP.Cone = 0.5
	SWEP.ConeVariance = 0

	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false

	--SWEP.ForceThirdPerson = true

	SWEP.Help = {"Left click: Arm explosive", "Right click: Detonate explosive"}

	function SWEP:GetViewModelPosition(pos, ang)
		if self:GetPlantEntity():IsValid() then
			pos = pos + 64 * ang:Up()
		end

		return self.BaseClass.GetViewModelPosition(self, pos, ang)
	end

	GAMEMODE:SetupCoolDownWeapon(SWEP)
end

SWEP.Slot = 0 --SWEP.Slot = 2

SWEP.PrintName = "Detonation Pack"

SWEP.HoldType = "grenade"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.01

SWEP.WalkSpeed = SPEED_FAST

util.PrecacheSound("weapons/c4/c4_plant.wav")
util.PrecacheSound("weapons/c4/c4_click.wav")

SWEP.CoolDown = 30

function SWEP:OnHolster()
	return self:GetPlantTime() == 0
end

function SWEP:Think()
	local owner = self.Owner
	local ent = self:GetPlantEntity()

	if ent:IsValid() then
		if SERVER and owner:KeyDown(IN_ATTACK) and (not self.PlantedTime or CurTime() >= self.PlantedTime) then
			ent:Explode()
			self.PlantedTime = nil
			self:SetPlantEntity(NULL)
		end

		return
	end

	if self:GetPlantTime() == 0 then return end

	--[[if not owner:KeyDown(IN_ATTACK) then
		self:SetPlantTime(0)
		self:SendWeaponAnim(ACT_VM_DRAW)
	else]] if self:GetPlantTime() <= CurTime() then
		if CLIENT then return end

		local ent = ents.Create("projectile_detpack")
		if ent:IsValid() then
			self.PlantedTime = CurTime() + 1.5

			ent:SetPos(owner:GetShootPos())
			ent:SetAngles(owner:GetAngles())
			ent:SetOwner(owner)
			ent:Spawn()
			ent:SetTeam(owner:Team())

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(true)
				phys:Wake()
				phys:SetVelocityInstantaneous(owner:GetAimVector() * 800)
				phys:AddAngleVelocity(Vector(0, 360, 0))
			end
			ent:SetPhysicsAttacker(owner)

			ent:EmitSound("weapons/strider_buster/Strider_Buster_stick1.wav") -- TODO: Needs resource

			self:SetPlantTime(0)
			self:SetPlantEntity(ent)

			self:ResetCoolDown()
		end
	end
end

function SWEP:CanPrimaryAttack()
	return self.Owner:IsIdle() and self:GetPlantTime() == 0 and not self.Owner:GetStateTable().CantUseWeapons and CurTime() >= self:GetCoolDown()
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self.PlantedTime = nil

	local owner = self.Owner
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetPlantTime(CurTime() + 2.8)

	if SERVER then
		self:EmitSound("weapons/c4/c4_click.wav", 65, 100)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:IsIdle()
	return true
end

function SWEP:GetPlantTime() return self:GetDTFloat(3) end
function SWEP:SetPlantTime(time) self:SetDTFloat(3, time) end
function SWEP:GetPlantEntity() return self:GetDTEntity(0) end
function SWEP:SetPlantEntity(ent) self:SetDTEntity(0, ent) end
