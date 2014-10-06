AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--local schdIdle = ai_schedule.New()
--schdIdle:EngTask("TASK_WAIT", 1)

function ENT:Initialize()
	self:SetModel("models/Characters/Hostage_01.mdl")

	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)

	self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND, CAP_MOVE_JUMP, CAP_MOVE_SHOOT, CAP_USE, CAP_AUTO_DOORS, CAP_OPEN_DOORS, CAP_TURN_HEAD, CAP_ANIMATEDFACE, CAP_FRIENDLY_DMG_IMMUNE))

	self:SetMaxYawSpeed(5000)

	self:SetUseType(SIMPLE_USE)
	self.NextPlayerUse = 0

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
end

function ENT:DoStartScheduleIdle()
	self:StartSchedule(schdIdle)
end

function ENT:Reset()
	self.ResetTime = nil
	local entlist = ents.FindByClass("hostage_entity")
	if #entlist > 0 then
		self:SetPos(entlist[math.random(#entlist)]:GetPos())
	end
end

function ENT:OnTakeDamage(dmginfo)
	if self.DEAD then return end

	if not self:GetCarry():IsValid() and dmginfo:GetAttacker():IsValid() and string.sub(dmginfo:GetAttacker():GetClass(), 1, 12) == "trigger_hurt" then
		self:Reset()
	else
		self:EmitSound("hostage/hpain/hpain"..math.random(6)..".wav")
	end
end 

function ENT:SelectSchedule()
	--self:StartSchedule(schdIdle)
end

local usesounds = file.Find("sound/hostage/huse/*.wav", "GAME")
local unusesounds = file.Find("sound/hostage/hunuse/*.wav", "GAME")
function ENT:StartCarry(ent)
	if ent and ent:IsValid() then
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetNoDraw(true)
		self:SetCarry(ent)
		self:EmitSound("hostage/huse/"..usesounds[math.random(#usesounds)])

		ent:SetState(STATE_CARRYHOSTAGE, nil, self)
	end
end

function ENT:EndCarry(dontcallstate, silent)
	local carry = self:GetCarry()
	if carry:IsValid() then
		self:SetPos(carry:GetPos())
		self:SetAngles(carry:GetAngles())

		if not silent then
			self:EmitSound("hostage/hunuse/"..unusesounds[math.random(#unusesounds)])
		end
		self.NextPlayerUse = CurTime() + 0.75

		if not dontcallstate and carry:GetState() == STATE_CARRYHOSTAGE then carry:EndState() end

		self:SetLastDrop(CurTime())
	end
	self:SetCarry(NULL)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)
	self:SetNoDraw(false)
	self:DropToFloor()
end

function ENT:Think()
	if self.ResetTime and CurTime() >= self.ResetTime then
		self:Reset()
	else
		local carry = self:GetCarry()
		if carry:IsValid() then
			if carry:IsPlayer() and carry:Alive() and carry:GetActiveWeapon():IsValid() and carry:GetActiveWeapon():GetClass() == "weapon_as_hostage" then
				self:SetPos(carry:GetPos())

				self:NextThink(CurTime())
				return true
			else
				self:EndCarry()
			end
		end
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
