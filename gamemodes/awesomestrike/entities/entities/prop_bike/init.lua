AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

--models/props_phx/normal_tire.mdl


ENT.MaximumAcceleration = 1200
ENT.YawForce = 300
ENT.RollForce = 200
ENT.Acceleration = 600
ENT.BrakeForce = 400

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.Model)

	--[[self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)]]

	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
		phys:SetDamping(0.1, 2.5)
		phys:Wake()
	end

	self:StartMotionController()
end

function ENT:OnRemove()
end

TEST1 = 8
TEST2 = -15
TEST3 = -32

local balancetrace = {mask = MASK_SOLID_BRUSHONLY, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local rollforce = 0
	local yawforce = 0
	local accel = 0

	if owner:KeyDown(IN_MOVELEFT) then
		yawforce = yawforce - self.YawForce
		rollforce = rollforce - self.RollForce
	end
	if owner:KeyDown(IN_MOVERIGHT) then
		yawforce = yawforce + self.YawForce
		rollforce = rollforce + self.RollForce
	end
	if owner:KeyDown(IN_BACK) then
		accel = accel - self.BrakeForce
	elseif owner:KeyDown(IN_FORWARD) then
		accel = accel + self.Acceleration
	end

	local pos = phys:GetPos()
	local ang = phys:GetAngles()
	local mass = phys:GetMass()
	local up = ang:Up()
	local right = ang:Right()
	local offset = up * TEST3
	local onground = false

	balancetrace.start = pos + right * TEST1
	balancetrace.endpos = balancetrace.start + offset
	local tr = util.TraceHull(balancetrace)
	if tr.Hit and 0 < tr.Fraction and tr.HitNormal:Distance(up) <= 1 and not tr.HitSky then
		phys:ApplyForceOffset(frametime * mass * TEST2 * tr.HitNormal, balancetrace.endpos)
		onground = true
	end

	balancetrace.start = pos - right * TEST1
	balancetrace.endpos = balancetrace.start + offset
	tr = util.TraceHull(balancetrace)
	if tr.Hit and 0 < tr.Fraction and tr.HitNormal:Distance(up) <= 1 and not tr.HitSky then
		phys:ApplyForceOffset(frametime * mass * TEST2 * tr.HitNormal, balancetrace.endpos)
		onground = true
	end

	phys:AddAngleVelocity(Vector(0, frametime * yawforce, frametime * rollforce))

	if onground then
		phys:ApplyForceCenter(frametime * mass * accel * phys:GetAngles():Forward())
	end

	return SIM_NOTHING
end

--[[function ENT:Think()
	self:AlignToPlayer()

	self:NextThink(CurTime())
	return true
end]]
