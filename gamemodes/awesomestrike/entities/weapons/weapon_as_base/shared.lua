if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("animations.lua")
end

if CLIENT then
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = true
	SWEP.ConeCrosshair = true
	SWEP.SlotPos = 0

	SWEP.SwayScale = 1
	SWEP.BobScale = 0.5

	SWEP.SprintViewRR = -7
	SWEP.SprintViewRU = -12
	SWEP.SprintViewRF = 0
	SWEP.SprintViewMR = 0
	SWEP.SprintViewMU = 0
	SWEP.SprintViewMF = -5.5

	include("animations.lua")
end

SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15
SWEP.Primary.BusyTime = SWEP.Primary.Delay + 0.1
SWEP.Primary.DefaultClip = 99999

SWEP.Cone = 2
SWEP.ConeVariance = 1

SWEP.NextSecondaryAttack = 0

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 99999
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "CombineCannon"
SWEP.Secondary.BusyTime = 0.1

SWEP.BulletDamage = 40
SWEP.BulletSpeed = 2900 -- Bullets travel about 1000 MPH but it's reduced about 5x for gameplay.
SWEP.BulletClass = "projectile_asbullet"

SWEP.MuzzleFlashEffect = "muzzleflash1"

SWEP.WalkSpeed = SPEED_NORMAL

SWEP.HoldType = "pistol"

SWEP.LastShoot = 0

SWEP.ShootingSpeed = 0.7

function SWEP:OnInitialize()
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self:SetWeaponSprintHoldType(self.SprintHoldType or self.HoldType)
	self:SetDeploySpeed(3)

	self:OnInitialize()

	if CLIENT then
		self:Anim_Initialize()
	end
end

function SWEP:SetWeaponSprintHoldType(t)
	local old = self.ActivityTranslate
	self:SetWeaponHoldType(t)
	local new = self.ActivityTranslate
	self.ActivityTranslate = old
	self.ActivityTranslateSprint = new
end

function SWEP:TranslateActivity(act)
	--[[if self.Owner:GetState() == STATE_SPRINT then
		return self.ActivityTranslateSprint[act]
	end]]

	if self.ActivityTranslate[act] ~= nil then
		return self.ActivityTranslate[act]
	end

	return -1
end

function SWEP:Move(move)
	if self:IsReloading() then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.8)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.8)
	elseif self:IsShooting() then
		move:SetMaxSpeed(move:GetMaxSpeed() * self.ShootingSpeed)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * self.ShootingSpeed)

		local owner = self.Owner
		if owner:GetState() == STATE_NONE and not owner:OnGround() and not owner.WallJumpInAir then
			local vel = move:GetVelocity()
			local maxvel = move:GetMaxSpeed() * 2.25
			if vel:Length2D() >= maxvel then
				local oldz = vel.z
				vel.z = 0
				vel:Normalize()
				vel = vel * maxvel
				vel.z = oldz
				move:SetVelocity(vel)
			end
		end
	end
end

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self.Owner, self)

	if self.PreHolsterClip1 then
		self:SetClip1(self.PreHolsterClip1)
		self.PreHolsterClip1 = nil
	end
	if self.PreHolsterClip2 then
		self:SetClip2(self.PreHolsterClip2)
		self.PreHolsterClip2 = nil
	end

	self:GiveWeaponStatus()

	if self.LuaAnim_Idle then
		self.Owner:SetLuaAnimation(self.LuaAnim_Idle)
	end

	return true
end

function SWEP:Holster()
	if self:OnHolster() then
		self:SetShootingEnd(0)
		if not self.CoolDown then
			self:SetReloadingEnd(0)
		end

		if self.Primary.Ammo ~= "none" then
			self.PreHolsterClip1 = self:Clip1()
		end
		if self.Secondary.Ammo ~= "none" then
			self.PreHolsterClip2 = self:Clip2()
		end

		self:RemoveWeaponStatus()
		return true
	end

	return false
end

function SWEP:OnRemove()
	self:RemoveWeaponStatus()

	if CLIENT then
		self:Anim_OnRemove()
	end
end

function SWEP:OnHolster()
	return true
end

function SWEP:IsIdle()
	return not self:IsShooting() --and not self:IsReloading()
end

function SWEP:AlterBulletAngles(pos, ang)
	if not self.SmartTarget and self.Owner:GetSkill() ~= SKILL_SMARTTARGETING then return end

	local owner = self.Owner

	owner:LagCompensation(true)

	local tr = owner:TraceHull(2048, MASK_SHOT, self.SmartTargetSize or 2, owner:GetAttackFilter())
	local trent = tr.Entity
	if trent and trent:IsValid() and trent:IsPlayer() then
		local eyeangles = owner:EyeAngles()
		local trentpos = trent:GetPos()
		trentpos.z = tr.HitPos.z
		local targetpos = trentpos + (trentpos:Distance(pos) / (self.BulletSpeed * 0.9)) * trent:GetVelocity()
		local newang = (targetpos - pos):Angle()
		newang.pitch = newang.pitch + math.AngleDifference(eyeangles.pitch, ang.pitch)
		newang.yaw = newang.yaw + math.AngleDifference(eyeangles.yaw, ang.yaw)
		ang = newang
	end

	owner:LagCompensation(false)

	return ang, true
end

function SWEP:Think()
	if self:GetReloadEnd() ~= 0 and self:GetReloadEnd() <= CurTime() and not self.CoolDown then
		self:SetReloadEnd(0)

		self:SetClip1(self.Primary.ClipSize)
		self:SetClip2(self.Secondary.ClipSize)
	end
end

function SWEP:DoShoot()
	local cone = self:GetCone()
	self:ShootBullet(self.BulletDamage, self.Primary.NumShots, cone)
end

function SWEP:GetCone()
	local cone = self.Cone
	local conevariance = self.ConeVariance
	local conemul = 0
	if self.Owner:OnGround() then
		if 25 < self.Owner:GetVelocity():Length() then
			if self.Owner:Crouching() then
				conemul = 0.2
			else
				conemul = -0.2
			end
		elseif self.Owner:Crouching() then
			conemul = 0.25
		end
	else
		conemul = -0.25
	end

	return cone * (1 - conemul * conevariance)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self.Owner:InterruptSpecialMoves()

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetShootingEnd(CurTime() + self.Primary.BusyTime)

	if self.Primary.Sound then
		self:EmitSound(self.Primary.Sound)
	end

	self:TakePrimaryAmmo(1)

	self:SendWeaponAnimation()
	self.Owner:DoAttackEvent()
	if self.MuzzleFlashEffect then
		local effectdata = EffectData()
			effectdata:SetEntity(self)
			effectdata:SetOrigin(self:GetPos())
		util.Effect(self.MuzzleFlashEffect, effectdata)
	end

	self.LastShoot = CurTime()
	self:DoShoot()
end

function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:Reload()
	if not self:IsReloading() and self:IsIdle() and not self.Owner:GetStateTable().CantUseWeapons and self:Clip1() < self.Primary.ClipSize and self:CanReload() and self.Primary.Ammo ~= "none" then
		self.Owner:DoReloadEvent()
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self:SetPlaybackRate(0.5)
		self:SetReloadEnd(CurTime() + self:SequenceDuration())
		if self.ReloadSound then
			self:EmitSound(self.ReloadSound)
		end
	end
end

function SWEP:CanReload()
	return true
end

function SWEP:CanPrimaryAttack(nocheckammo)
	if self.Owner:GetStateTable().CantUseWeapons or self:IsReloading() then return false end

	if self:Clip1() == 0 then
		if nocheckammo then
			self:EmitSound("weapons/pistol/pistol_empty.wav", 50, 100)
			self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		end

		return false
	end

	return self:GetNextPrimaryFire() <= CurTime()
end

function SWEP:SecondaryAttack()
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	self:Anim_ViewModelDrawn()
end

function SWEP:DrawWorldModel()
	self:Anim_DrawWorldModel()
end

--[[local SprintPower = 0
local yawdiff = 0
local pitchdiff = 0]]
function SWEP:GetViewModelPosition(pos, ang)
	--[[if self.Owner:IsSprinting() then
		SprintPower = math.Approach(SprintPower, 1, FrameTime() * 3)
	elseif SprintPower > 0 then
		SprintPower = math.Approach(SprintPower, 0, FrameTime() * 5)
	end

	if SprintPower > 0 then
		pos = pos
		+ SprintPower * self.SprintViewMF * ang:Forward()
		+ SprintPower * self.SprintViewMU * ang:Up()
		+ SprintPower * self.SprintViewMR * ang:Right()

		ang = ang * 1

		ang:RotateAroundAxis(ang:Right(), SprintPower * self.SprintViewRR)
		if self.ViewModelFlip then
			ang:RotateAroundAxis(ang:Up(), SprintPower * self.SprintViewRU)
		else
			ang:RotateAroundAxis(ang:Up(), SprintPower * self.SprintViewRU * -1)
		end
		ang:RotateAroundAxis(ang:Forward(), SprintPower * self.SprintViewRF)
	end

	local rate = FrameTime() * 45
	local alteredang, _ = self:AlterBulletAngles(pos, ang)
	if alteredang then
		pitchdiff = math.Approach(pitchdiff, math.AngleDifference(ang.pitch, alteredang.pitch) * 0.7, rate)
		yawdiff = math.Approach(yawdiff, (self.ViewModelFlip and math.AngleDifference(ang.yaw, alteredang.yaw) or math.AngleDifference(alteredang.yaw, ang.yaw)) * 0.7, rate)
	else
		pitchdiff = math.Approach(pitchdiff, 0, 0)
		yawdiff = math.Approach(yawdiff, 0, 0)
	end
	if pitchdiff ~= 0 or yawdiff ~= 0 then
		pos = pos + pitchdiff * 0.04 * ang:Up() + yawdiff * 0.04 * ang:Right()
		ang:RotateAroundAxis(ang:Right(), pitchdiff)
		ang:RotateAroundAxis(ang:Up(), yawdiff)
	end]]

	return pos, ang
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText(self.PrintName, "ass_smaller_shadow", x + wide * 0.5, y + tall * 0.5, COLOR_YELLOW, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local CrossHairScale = 1
local texGear = surface.GetTextureID("awesomestrike/gear2")
function SWEP:DrawHUD()
	if self.DrawCrosshair or not self.ConeCrosshair or self.Owner:CallStateFunction("DontDrawWeaponHUD", self) then return end

	local x = w * 0.5
	local y = h * 0.5

	local scalebyheight = (h / 768) * 0.2

	local scale = self:GetCone() * scalebyheight
	CrossHairScale = math.Approach(CrossHairScale, scale, FrameTime() * 5 + math.abs(CrossHairScale - scale) * 0.012)

	local midarea = 40 * CrossHairScale
	local length = scalebyheight * 24 + midarea / 4

	--surface.SetDrawColor(0, 230, 0, 160)
	surface.SetDrawColor(255, 177, 0, 160)
	surface.DrawRect(x - midarea - length, y - 2, length, 4)
	surface.DrawRect(x + midarea, y - 2, length, 4)
	surface.DrawRect(x - 2, y - midarea - length, 4, length)
	surface.DrawRect(x - 2, y + midarea, 4, length)
	surface.DrawRect(x - 2, y - 2, 4, 4)

	surface.SetDrawColor(0, 0, 0, 160)
	surface.DrawOutlinedRect(x - midarea - length, y - 2, length, 4)
	surface.DrawOutlinedRect(x + midarea, y - 2, length, 4)
	surface.DrawOutlinedRect(x - 2, y - midarea - length, 4, length)
	surface.DrawOutlinedRect(x - 2, y + midarea, 4, length)
	surface.DrawOutlinedRect(x - 2, y - 2, 4, 4)

	midarea = math.Clamp(midarea, 12, 32)

	if self:IsReloading() then
		local geardistance = midarea * 2 + length + 8
		local geary = y - geardistance

		surface.SetTexture(texGear)
		surface.SetDrawColor(color_black_alpha120)
		surface.DrawTexturedRectRotated(x + geardistance, y, midarea + 2, midarea + 2, 0)

		local duration = 1
		if self.CoolDown then
			duration = self.CoolDown * (self.Owner:GetSkill() == SKILL_MECHANICALMASTERY and 0.5 or 1)
		else
			duration = self:SequenceDuration()
		end

		local baserotation = (1 - (self:GetReloadEnd() - CurTime()) / duration) * 360
		for i=0, 4 do
			local rotation = baserotation - i * 5
			if rotation >= 0 then
				local radrotation = math.rad(rotation)
				surface.SetDrawColor(255, 177, 0, 220 - i * 50)
				surface.DrawTexturedRectRotated(x + math.cos(radrotation) * geardistance, y + math.sin(radrotation) * geardistance, midarea + 2, midarea + 2, rotation * -2)
			end
		end
	elseif self.Primary.Ammo ~= "none" and self:Clip1() == 0 then
		surface.SetTexture(texGear)
		surface.SetDrawColor(255, 0, 0, 220)
		surface.DrawTexturedRectRotated(x + midarea * 2 + length + 8, y, midarea, midarea, UnPredictedCurTime() * 180)
	end
end
