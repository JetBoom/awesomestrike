AddCSLuaFile()

if CLIENT then
	SWEP.ForceThirdPerson = true
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = false
	
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.WElements = {
		["deco"] = { type = "Sprite", sprite = "sprites/glow03", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -3), size = { x = 12, y = 12 }, color = Color(255, 177, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["deco1"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(1.5, 5, -5), angle = Angle(160, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 200, 40, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco1+"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(1.5, -6, -5), angle = Angle(160, 270, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 200, 40, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["deco+"] = { type = "Sprite", sprite = "sprites/glow03", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(3, -0.5, -3), size = { x = 12, y = 12 }, color = Color(255, 177, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["base"] = { type = "Model", model = "models/peanut/conansword.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5, 3, -2), angle = Angle(-5, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Slot = 0

SWEP.PrintName = "Berserker Sword"

SWEP.HoldType = "melee2"

SWEP.ViewModel = "models/weapons/V_Stunbaton.mdl"
SWEP.WorldModel = "models/peanut/conansword.mdl"

SWEP.Base = "weapon_as_base"

SWEP.IsMelee = true

SWEP.Primary.Delay = 0.9
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 25

SWEP.Secondary.Automatic = true

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingDuration = 0.15

SWEP.UppercutSwingDuration = 0.25
SWEP.UppercutDelay = 1.4
SWEP.UppercutDamage = 15

function SWEP:GetSwingEnd() return self:GetDTFloat(3) end
function SWEP:SetSwingEnd(time) self:SetDTFloat(3, time) end
function SWEP:GetSwingPowerAttack() return self:GetDTBool(3) end
function SWEP:SetSwingPowerAttack(bool) self:SetDTBool(3, bool) end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner
	owner:InterruptSpecialMoves()

	self:Swing()

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self.Owner
	if not owner:IsIdle() then return end

	owner:InterruptSpecialMoves()

	self:Swing(self.UppercutSwingDuration, true)

	self:SetNextPrimaryAttack(CurTime() + self.UppercutDelay)
end

function SWEP:Reload()
	if not self:CanPrimaryAttack() then return end

	self.Owner:InterruptSpecialMoves()
	self.Owner:SetState(STATE_BERSERKERSWORDGUARD)
end

function SWEP:Swing(duration, powerattack)
	duration = duration or self.SwingDuration
	if powerattack then
		self.Owner:ResetLuaAnimation("bsword_uppercut")
	else
		self.Owner:DoAttackEvent()
	end
	self:EmitSound("npc/zombie/claw_miss1.wav", 75, math.Rand(75, 80))
	self:SetSwingEnd(CurTime() + duration)
	if powerattack then
		self:SetSwingPowerAttack(true)
	end
end

function SWEP:GetSwingTraces()
	local powerattack = self:GetSwingPowerAttack()
	return self.Owner:PenetratingTraceHull(self:GetSwingDistance(powerattack), MASK_SOLID, self:GetSwingSize(powerattack), self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:GetSwingDistance(powerattack)
	return 56
end

function SWEP:GetSwingSize(powerattack)
	return 16
end

function SWEP:Swung()
	if not IsFirstTimePredicted() then return end

	local owner = self.Owner
	local powerattack = self:GetSwingPowerAttack()

	local eyepos = owner:EyePos()

	owner:LagCompensation(true)
	local traces = self:GetSwingTraces()
	owner:LagCompensation(false)

	local startpos = owner:GetShootPos()
	for _, trace in pairs(traces) do
		if not trace.Hit or trace.HitPos:Distance(startpos) > self:GetSwingDistance(powerattack) + 16 then continue end

		local decalstart = trace.HitPos + trace.HitNormal * 8
		local decalend = trace.HitPos - trace.HitNormal * 8
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			if powerattack then
				self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
			else
				self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav")
			end

			util.Decal("Blood", decalstart, decalend)
		else
			self:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav")
		end
		util.Decal("ManhackCut", decalstart, decalend)

		local ent = trace.Entity
		if ent and ent:IsValid() then
			local blocked = ent.OnHitWithMelee and ent:OnHitWithMelee(owner, self, trace, powerattack)

			if SERVER then
				if powerattack then
					if ent:IsPlayer() then
						if ent:GetState() ~= STATE_KNOCKEDDOWN then
							ent:SetLocalVelocity(Vector(0, 0, 0))
							ent:ThrowFromPositionSetZ(owner:GetPos(), 40, 19)
						end	
					else
						ent:ThrowFromPositionSetZ(owner:GetPos(), 40, 19)
					end
				else
					ent:ThrowFromPositionSetZ(owner:GetPos(), blocked and 40 or 80)
				end
			end

			if not blocked then
				ent:TakeSpecialDamage(powerattack and self.UppercutDamage or self.Primary.Damage, DMG_SLASH, owner, self, trace.HitPos)
			end
		end
	end

	self:SetSwingPowerAttack(false)
end

function SWEP:OnKnockedDown(oldstate)
	self:SetNextPrimaryAttack(0)
	self:SetSwingEnd(0)
	self:SetSwingPowerAttack(false)
end
SWEP.OnFlinched = SWEP.OnKnockedDown

local function IsValidPlayer(pl)
	return pl and pl:IsValid() and pl:IsPlayer()
end
function SWEP:Think()
	if self:GetSwingEnd() > 0 and CurTime() >= self:GetSwingEnd() then
		self:SetSwingEnd(0)
		self:Swung()
	end

	if self.Owner:GetState() == STATE_BERSERKERSWORDGUARD then
		if self.Owner:KeyDown(IN_RELOAD) then
			self:SetNextPrimaryAttack(CurTime() + 0.25)
		else
			self.Owner:EndState()
		end
	end

	self:NextThink(CurTime())
	return true
end

function SWEP:OnHolster()
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_BERSERKERSWORDGUARD
end

function SWEP:IsIdle()
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_BERSERKERSWORDGUARD
end

function SWEP:CanPrimaryAttack()
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_BERSERKERSWORDGUARD and not self.Owner:GetStateTable().CantUseWeapons
end

RegisterLuaAnimation('bsword_uppercut', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 53
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 62
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = 34
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -12,
					RR = -3,
					RF = 39
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = -9
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 88
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 60,
					RR = 31
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -6
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -27
				},
				['ValveBiped.Bip01_Pelvis'] = {
				}
			},
			FrameRate = 5.33
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 53
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 29,
					RR = -20
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -56,
					RR = -3,
					RF = 96
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = -9
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 66
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 88
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 60,
					RR = 31
				},
				['ValveBiped.Bip01_Pelvis'] = {
				}
			},
			FrameRate = 13.33
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 53
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 86
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -47
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 25
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -3,
					RR = 31
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 24
				}
			},
			FrameRate = 13.33
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 53
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -82,
					RR = 44,
					RF = -3
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 86
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -47
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 25
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 18,
					RR = 31
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 24
				}
			},
			FrameRate = 6.66
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 53
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -82,
					RR = 44,
					RF = -3
				},
				['ValveBiped.Bip01_Pelvis'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 33
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 86
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 24
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 25
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 18,
					RR = 31
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -47
				}
			},
			FrameRate = 5.33
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_Pelvis'] = {
				}
			},
			FrameRate = 2.66
		}
	},
	Type = TYPE_GESTURE
})

RegisterLuaAnimation('bswordspin', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 47
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -42,
					RR = 8
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 75,
					RR = 49,
					RF = -10
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -2,
					RF = 28
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 12
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 102
				}
			},
			FrameRate = 4
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 47
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -42,
					RR = 8
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = 360
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 75,
					RR = 49,
					RF = -10
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -2,
					RF = 28
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 12
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 102
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 47
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -33,
					RR = -4
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 23,
					RR = -16,
					RF = 720
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 42,
					RR = 26,
					RF = -15
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -2,
					RF = 28
				},
				['ValveBiped.Bip01_Spine1'] = {
					RR = -6,
					RF = 12
				},
				['ValveBiped.Bip01_Spine4'] = {
					RR = -3,
					RF = 10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 84
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 15
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -21,
					RR = -7
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -23,
					RR = 20,
					RF = 1080
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 75,
					RR = 49,
					RF = -10
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -2,
					RF = 28
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = -1,
					RR = 5,
					RF = 15
				},
				['ValveBiped.Bip01_Spine4'] = {
					RR = 7,
					RF = 10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 90
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 26
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -46,
					RR = -27,
					RF = 13
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -12,
					RR = -17,
					RF = 1440
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 92,
					RR = 49,
					RF = -16
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -6,
					RR = -32,
					RF = -53
				},
				['ValveBiped.Bip01_Spine1'] = {
					RR = 7,
					RF = 12
				},
				['ValveBiped.Bip01_Spine4'] = {
					RR = -13,
					RF = 10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 82
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 47
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -42,
					RR = 8
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -28
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = 360
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 75,
					RR = 49,
					RF = -10
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -2,
					RF = 28
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 12
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 8
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 102
				}
			},
			FrameRate = 8
		}
	},
	RestartFrame = 2,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		return pl:GetState() == STATE_BERSERKERSWORDGUARD
	end,
	Type = TYPE_STANCE
})
