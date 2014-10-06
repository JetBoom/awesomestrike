AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetSequence(9)
	self:SetPlaybackRate(1)
	self:SetModelScale(0.25, 0)
end
