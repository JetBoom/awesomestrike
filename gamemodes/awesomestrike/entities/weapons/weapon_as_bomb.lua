AddCSLuaFile()

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = false

	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false

	SWEP.Help = {"Left click: Plant bomb at bomb site."}
end

SWEP.Slot = 3

SWEP.PrintName = "C4 Explosive"

SWEP.HoldType = "slam"

SWEP.Base = "weapon_as_base"

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

SWEP.TOnly = true
SWEP.Undroppable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.01

SWEP.WalkSpeed = SPEED_FAST

util.PrecacheSound("weapons/c4/c4_plant.wav")
util.PrecacheSound("weapons/c4/c4_click.wav")

function SWEP:OnHolster()
	return self:GetPlantTime() == 0
end

function SWEP:Think()
	if self:GetPlantTime() <= 0 then return end

	local owner = self.Owner
	if not owner.CanPlantBomb or not owner:KeyDown(IN_ATTACK) or owner:GetState() ~= STATE_PLANTING then
		self:SetPlantTime(0)
		self:SendWeaponAnim(ACT_VM_DRAW)
		owner:EndState()
	elseif self:GetPlantTime() <= CurTime() then
		if CLIENT then return end

		owner:EndState()

		if #ents.FindByClass("planted_bomb") > 0 then return end

		local ent = ents.Create("planted_bomb")
		if ent:IsValid() then
			ent:SetPos(owner:GetPos())
			ent:Spawn()
			ent:EmitSound("weapons/c4/c4_plant.wav")

			GAMEMODE:AddNotice(owner:Name().." has planted the bomb!~sradio/bombpl.wav", nil, COLID_RED)

			self:SetPlantTime(-1)

			local bombclass = self:GetClass()
			for _, pl in pairs(player.GetAll()) do
				pl:StripWeapon(bombclass)
			end
		end
	end
end

function SWEP:CanPrimaryAttack()
	return not self.Owner:GetStateTable().CantUseWeapons
end

function SWEP:PrimaryAttack()
	if self:GetPlantTime() ~= 0 then return end

	local owner = self.Owner
	if owner.CanPlantBomb then
		if owner:IsOnGround() and owner:GetState() == STATE_NONE and owner:WaterLevel() == 0 then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			if owner:GetState() == STATE_MECHANICALMASTERY then
				self:SetPlantTime(CurTime() + 1.8)
			else
				self:SetPlantTime(CurTime() + 2.8)
			end
			owner:SetState(STATE_PLANTING)

			if SERVER then
				self:EmitSound("weapons/c4/c4_click.wav", 65, 100)
			end
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:IsIdle()
	return true
end

function SWEP:GetPlantTime() return self:GetDTFloat(3) end
function SWEP:SetPlantTime(time) self:SetDTFloat(3, time) end
