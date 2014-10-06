include("shared.lua")

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:SetModelScale(1.5, 0)
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 128))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(16, 24)
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

function ENT:SetupAngles(vel)
	if vel ~= vector_origin then
		self:SetAngles(vel:Angle())
	end
end

local matBeam = Material("effects/spark")
local matGlow = Material("sprites/glow04_noz")
local colBeam = Color(255, 255, 255)
local color_white = Color(255, 255, 255)

function ENT:DoColors()
	local col = self:GetColor()
	colBeam.r = col.r
	colBeam.g = col.g
	colBeam.b = col.b
	colBeam.a = col.a
end

function ENT:EmitParticles()
	local particle = self.Emitter:Add("sprites/glow04_noz", self:GetPos() + VectorRand():GetNormalized() * math.Rand(-2, 2))
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(1)
	particle:SetRoll(math.Rand(0, 360))
	local r, g, b, a = self:GetColor()
	particle:SetColor(r, g, b)
end

function ENT:DrawGlow()
	local pos = self:GetPos()
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 6, 6, colBeam)
	render.DrawSprite(pos, 3, 3, color_white)
end

function ENT:Draw()
	local vel = self:GetVelocity()
	self:SetupAngles(vel)

	self:DrawModel()

	self:DoColors()

	vel:Normalize()
	local start = self:GetPos()
	local endpos = start - vel * 100
	render.SetMaterial(matBeam)
	render.DrawBeam(start, endpos, 4, 1, 0, colBeam)
	render.DrawBeam(start, endpos, 2, 1, 0, colBeam)
	render.DrawBeam(start, endpos, 1, 1, 0, color_white)

	self:DrawGlow()

	self:EmitParticles()
end
