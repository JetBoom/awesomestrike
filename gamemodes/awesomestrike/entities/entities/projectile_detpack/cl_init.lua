include("shared.lua")

util.PrecacheSound("npc/turret_wall/turret_loop1.wav")

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "npc/turret_wall/turret_loop1.wav")
	self:PlayAmbientSound()
end

function ENT:PlayAmbientSound()
	self.AmbientSound:PlayEx(0.75, math.Clamp(self:GetVelocity():Length() * 0.2 + math.sin(CurTime()), 80, 255))
end

function ENT:Think()
	self:PlayAmbientSound()
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:Draw()
	local teamid = self:GetTeam()
	local playerteam = MySelf:IsValid() and MySelf:Team() or -1
	if teamid == playerteam then
		render.SetColorModulation(0.4, 1, 0.4)
		render.SuppressEngineLighting(true)
	else
		local col = team.GetColor(teamid) or color_white
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
	end

	self:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)
end
