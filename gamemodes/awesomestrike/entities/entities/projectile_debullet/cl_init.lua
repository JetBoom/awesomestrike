include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetModelScale(0.25, 0)
	self:SetSequence(9)
	self:SetPlaybackRate(1)

	self.Rotation = math.Rand(0, 360)
	self.RotationRate = math.Rand(-360, 360)
end

function ENT:SetupAngles(vel)
	local ang = vel ~= vector_origin and vel:Angle() or self:GetAngles()
	self.Rotation = self.Rotation + self.RotationRate * FrameTime()
	ang.roll = self.Rotation
	self:SetAngles(ang)
end

function ENT:Draw()
	self.BaseClass.Draw(self)
end
