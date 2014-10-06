AddCSLuaFile()

if CLIENT then
	SWEP.ForceThirdPerson = true
	SWEP.DrawCrosshair = false
	SWEP.ConeCrosshair = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.WElements = {
		["bat+"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -30), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 0.349), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["batglow"] = { type = "Sprite", sprite = "sprites/glow01", bone = "ValveBiped.Bip01_R_Hand", rel = "bat+", pos = Vector(0, 0, 0), size = { x = 32, y = 64 }, color = Color(237, 0, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
		["bat++++++"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-3.5, 0, -30), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.319), color = Color(190, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["bat+++++++"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -54.5), angle = Angle(0, 0, 180), size = Vector(0.25, 0.25, 0.009), color = Color(190, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["bat+++"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3.5, -30), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.319), color = Color(190, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["bat+++++"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(3.5, 0, -30), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.319), color = Color(190, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["bat++"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -53.6), angle = Angle(0, 0, 180), size = Vector(0.5, 0.5, 0.019), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["bat++++"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 3.5, -30), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.319), color = Color(190, 0, 255, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 1, 0), angle = Angle(0, 0, 0), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["bat"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -22), angle = Angle(0, 0, 0), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Slot = 0

SWEP.PrintName = "Shockwave Bat"

SWEP.HoldType = "melee2"

SWEP.ViewModel = "models/weapons/V_Stunbaton.mdl"
SWEP.WorldModel = "models/weapons/W_stunbaton.mdl"

SWEP.Base = "weapon_as_base"

SWEP.IsMelee = true

SWEP.Primary.Delay = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 39

SWEP.Secondary.Automatic = true

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingDuration = 0.25

SWEP.SlamRadius = 92
SWEP.SlamDamage = 45
SWEP.SlamForce = 256
SWEP.SlamDistance = 80
SWEP.SlamDuration = 1
SWEP.SlamDelay = 2

function SWEP:GetSwingEnd() return self:GetDTFloat(3) end
function SWEP:SetSwingEnd(time) self:SetDTFloat(3, time) end

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
	if not owner:StandingOnSomething() then return end

	owner:InterruptSpecialMoves()

	owner:SetState(STATE_SHOCKWAVEBATSLAMATTACK, self.SlamDuration)

	self:SetNextPrimaryAttack(CurTime() + self.SlamDelay)
end

function SWEP:Reload()
	if not self:CanPrimaryAttack() then return end

	self.Owner:InterruptSpecialMoves()
	self.Owner:SetState(STATE_SHOCKWAVEBATGUARD)
end

function SWEP:Swing(duration)
	duration = duration or self.SwingDuration
	self.Owner:ResetLuaAnimation("shockwavebatbigswing")
	self:SetSwingEnd(CurTime() + duration)
end

function SWEP:OnKnockedDown(oldstate)
	self:SetNextPrimaryAttack(0)
	self:SetSwingEnd(0)
end
SWEP.OnFlinched = SWEP.OnKnockedDown

function SWEP:ShockWaveBatSlamEnded(newstate)
	local owner = self.Owner
	local ownerpos = owner:LocalToWorld(owner:OBBCenter())
	local tr1 = util.TraceLine({start = ownerpos, endpos = ownerpos + owner:SyncAngles():Forward() * self.SlamDistance, mask = MASK_SOLID_BRUSHONLY})
	local pos1 = tr1.HitPos + tr1.HitNormal * 2

	local tr2 = util.TraceLine({start = pos1, endpos = pos1 + Vector(0, 0, -64), mask = MASK_SOLID_BRUSHONLY})
	local pos = tr2.HitPos + tr2.HitNormal

	if SERVER then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetNormal(Vector(0, 0, 1))
		util.Effect("swbatslamattack", effectdata, true, true)
	end

	util.ScreenShake(pos, 32, 64, 1, self.SlamRadius * 4)

	local myteam = owner:Team()
	for _, ent in pairs(ents.FindInSphere(pos, self.SlamRadius)) do
		if ent:IsPlayer() and (ent:Team() == myteam or not ent:Alive()) then continue end

		local nearest = ent:NearestPoint(pos)
		if TrueVisible(pos, nearest) then
			local mul = (1 - nearest:Distance(pos) / self.SlamRadius) * 0.5 + 0.5
			ent:ThrowFromPositionSetZ(pos, self.SlamForce, 2)
			ent:TakeSpecialDamage(self.SlamDamage * mul, DMG_CLUB, owner, self, pos)
		end
	end
end

function SWEP:GetSwingTraces()
	return self.Owner:PenetratingTraceHull(self:GetSwingDistance(), MASK_SOLID, self:GetSwingSize(), self.Owner:GetMeleeAttackFilter(self))
end

function SWEP:GetSwingDistance()
	return 64
end

function SWEP:GetSwingSize()
	return 16
end

function SWEP:Swung()
	if not IsFirstTimePredicted() then return end

	local owner = self.Owner

	self:EmitSound("npc/zombie/claw_miss1.wav", 75, math.Rand(55, 65))

	owner:LagCompensation(true)
	local traces = self:GetSwingTraces()
	owner:LagCompensation(false)

	local startpos = owner:GetShootPos()
	for _, trace in pairs(traces) do
		if not trace.Hit or trace.HitPos:Distance(startpos) > self:GetSwingDistance() + 16 then continue end

		local decalstart = trace.HitPos + trace.HitNormal * 8
		local decalend = trace.HitPos - trace.HitNormal * 8
		util.Decal("Blood", decalstart, decalend)
		util.Decal("Impact.Concrete", decalstart, decalend)

		self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(3)..".wav")

		local ent = trace.Entity
		if ent and ent:IsValid() then
			local blocked = ent.OnHitWithMelee and ent:OnHitWithMelee(owner, self, trace)

			if SERVER then
				ent:ThrowFromPositionSetZ(owner:GetPos(), blocked and 200 or 420, nil, true)
			end
			if not blocked then
				ent:TakeSpecialDamage(self.Primary.Damage, DMG_CLUB, owner, self, trace.HitPos)
			end
		end
	end
end

function SWEP:Think()
	if self:GetSwingEnd() > 0 and CurTime() >= self:GetSwingEnd() then
		self:SetSwingEnd(0)
		self:Swung()
	end

	if self.Owner:GetState() == STATE_SHOCKWAVEBATGUARD then
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
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_SHOCKWAVEBATGUARD
end

function SWEP:IsIdle()
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_SHOCKWAVEBATGUARD
end

function SWEP:CanPrimaryAttack()
	return CurTime() >= self:GetNextPrimaryAttack() and self.Owner:GetState() ~= STATE_SHOCKWAVEBATGUARD and not self.Owner:GetStateTable().CantUseWeapons
end

function SWEP:GetKillAction(pl, attacker, dmginfo)
	return KILLACTION_SHOCKWAVEBAT, nil
end

RegisterLuaAnimation('shockwavebatjumpattack', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -42
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -105,
					RR = 30,
					RF = 28
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -151,
					RR = -25,
					RF = 52
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 23
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -19
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = -7
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -17
				},
				['ValveBiped.Bip01_L_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 12
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -4,
					RR = -4,
					RF = -8
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 29,
					RF = -45
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -80
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -22,
					RF = 14
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = 44
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -32
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 13
				},
				['ValveBiped.Bip01_L_Foot'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -10,
					RF = 14
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -22,
					RR = 8
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -96,
					RR = 17,
					RF = -5
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -165,
					RR = -19,
					RF = 68
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = -21,
					RR = 23,
					RF = 47
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -44
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 39
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = 39
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = -17
				},
				['ValveBiped.Bip01_L_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 64
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = -22,
					RF = 14
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RF = 44
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 29,
					RF = -45
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = 26,
					RR = -6,
					RF = -8
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -19
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -32
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = -7
				},
				['ValveBiped.Bip01_L_Foot'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 29,
					RF = -5
				}
			},
			FrameRate = 1.5
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -19
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -57,
					RR = 30,
					RF = 33
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -104,
					RR = -38,
					RF = 72
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 16,
					RR = -59,
					RF = 34
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -17,
					RR = -11,
					RF = 23
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 6
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = -16,
					RR = -10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 10,
					RF = 7
				},
				['ValveBiped.Bip01_L_Toe0'] = {
					RU = -45,
					RR = 3,
					RF = 14
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 116,
					RR = 4
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 29,
					RF = -53
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RR = -48
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -33,
					RF = -155
				},
				['ValveBiped.Bip01_Spine'] = {
					RU = 26
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 22,
					RF = 34
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -65,
					RR = -30
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -52,
					RR = -8
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 118,
					RF = 49
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = -9,
					RR = -18,
					RF = 12
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -54,
					RR = 35,
					RF = 8
				}
			},
			FrameRate = 5
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -19
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -57,
					RR = 30,
					RF = 33
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -104,
					RR = -38,
					RF = 72
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = 16,
					RR = -59,
					RF = 34
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -17,
					RR = -11,
					RF = 23
				},
				['ValveBiped.Bip01_Spine4'] = {
					RU = 6
				},
				['ValveBiped.Bip01_R_Foot'] = {
					RU = -16,
					RR = -10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RU = 10,
					RF = 7
				},
				['ValveBiped.Bip01_L_Toe0'] = {
					RU = -45,
					RR = 3,
					RF = 14
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 116,
					RR = 4
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 29,
					RF = -53
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RR = -48
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -33,
					RF = -155
				},
				['ValveBiped.Bip01_Spine'] = {
					RU = 26
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = -9,
					RR = -18,
					RF = 12
				},
				['ValveBiped.Bip01_L_Calf'] = {
					RU = 118,
					RF = 49
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -65,
					RR = -30
				},
				['ValveBiped.Bip01_R_Toe0'] = {
					RU = -52,
					RR = -8
				},
				['ValveBiped.Bip01_Spine1'] = {
					RU = 22,
					RF = 34
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -54,
					RR = 35,
					RF = 8
				}
			},
			FrameRate = 2
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -88
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -43,
					RR = -23,
					RF = 18
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -72,
					RR = 18
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 3
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = -3,
					RR = -20,
					RF = -10
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -12,
					RR = 6,
					RF = 23
				},
				['ValveBiped.Bip01_L_Thigh'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -124,
					RF = 6
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RR = 13,
					RF = 6
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 1,
					RR = 6
				}
			},
			FrameRate = 1
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -88
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -43,
					RR = -23,
					RF = 18
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -72,
					RR = 18
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Foot'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_Toe0'] = {
				},
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 3
				},
				['ValveBiped.Bip01_L_Thigh'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -12,
					RR = 6,
					RF = 23
				},
				['ValveBiped.Bip01_L_Foot'] = {
					RU = -3,
					RR = -20,
					RF = -10
				},
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RR = 13,
					RF = 6
				},
				['ValveBiped.Bip01_R_Toe0'] = {
				},
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = -124,
					RF = 6
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 1,
					RR = 6
				}
			},
			FrameRate = 1
		}
	},
	RestartFrame = 6,
	StartFrame = 1,
	Type = TYPE_SEQUENCE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		return pl:GetState() == STATE_SHOCKWAVEBATSLAMATTACK or pl:GetState() == STATE_SHOCKWAVEBATSLAMATTACKEND
	end
})

RegisterLuaAnimation('shockwavebatbigswing', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
					RF = -24
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 34,
					RR = -37
				},
				['ValveBiped.Bip01_Head1'] = {
					RU = 14,
					RR = -2,
					RF = 75
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = 12,
					RR = 38,
					RF = 21
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -16,
					RR = 10
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = -12,
					RR = -18,
					RF = 12
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RU = -2,
					RR = -18,
					RF = 15
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 29
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = -22
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = -10
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = -9
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 66,
					RR = 10
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = -9
				}
			},
			FrameRate = 4.8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -6,
					RR = -3,
					RF = -21
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -84
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -58,
					RR = -6,
					RF = 56
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 26
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 27,
					RR = 14,
					RF = 48
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = -1
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 44
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 27
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 54
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 18
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -12,
					RR = 11,
					RF = -23
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 79
				}
			},
			FrameRate = 8
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -6,
					RR = -3,
					RF = -21
				},
				['ValveBiped.Bip01_Head1'] = {
					RF = -84
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -58,
					RR = -6,
					RF = 56
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 26
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 27,
					RR = 14,
					RF = 48
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = -1
				},
				['ValveBiped.Bip01_Spine1'] = {
					RF = 44
				},
				['ValveBiped.Bip01_Spine4'] = {
					RF = 27
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 79
				},
				['ValveBiped.Bip01_Spine2'] = {
					RF = 18
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -12,
					RR = 11,
					RF = -23
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = 54
				}
			},
			FrameRate = 4.57
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_Spine'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				},
				['ValveBiped.Bip01_Head1'] = {
				},
				['ValveBiped.Bip01_R_Hand'] = {
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_L_Hand'] = {
				},
				['ValveBiped.Bip01_L_Clavicle'] = {
				},
				['ValveBiped.Bip01_R_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine4'] = {
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
				},
				['ValveBiped.Bip01_Spine2'] = {
				},
				['ValveBiped.Bip01_L_Forearm'] = {
				},
				['ValveBiped.Bip01_Spine1'] = {
				}
			},
			FrameRate = 2.66
		}
	},
	Type = TYPE_GESTURE
})

RegisterLuaAnimation('swbguard', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Clavicle'] = {
					RR = 42
				},
				['ValveBiped.Bip01_L_Forearm'] = {
					RU = -25
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = 18,
					RR = -26,
					RF = -6
				},
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = 31,
					RR = -48,
					RF = -17
				},
				['ValveBiped.Bip01_R_Hand'] = {
					RU = -36,
					RR = -9,
					RF = -48
				},
				['ValveBiped.Bip01_R_Clavicle'] = {
					RR = 34
				},
				['ValveBiped.Bip01_L_Hand'] = {
					RU = 1,
					RR = -82,
					RF = 77
				},
				['ValveBiped.Bip01_R_Forearm'] = {
					RU = 47,
					RR = 8,
					RF = -14
				}
			},
			FrameRate = 1
		}
	},
	Type = TYPE_POSTURE,
	ShouldPlay = function(pl, sGestureName, tGestureTable, iCurFrame, tFrameData)
		return pl:GetState() == STATE_SHOCKWAVEBATGUARD
	end,
	TimeToArrive = 0.15
})
