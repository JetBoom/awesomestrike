include("shared.lua")

ENT.EffectLifeTime = 1

function ENT:GetDeltaPower()
	return math.min((CurTime() - self:GetSpawnTime()) / self.EffectLifeTime, 1)
end

function ENT:Initialize()
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 1280))

	if self:GetSpawnTime() == 0 then
		self:SetSpawnTime(CurTime())
	end
end

function ENT:Think()
	if not self.PlayedCrashSound and self:GetDeltaPower() >= 0.9 then
		self.PlayedCrashSound = true

		self:EmitSound("physics/concrete/boulder_impact_hard"..math.random(4)..".wav")

		local pos = self:GetPos() + Vector(0, 0, self:OBBMins().z * 0.5)
		local ang = Angle(0, 0, 0)
		local up = Vector(0, 0, 1)

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)

		for i=1, 45 do
			ang:RotateAroundAxis(up, 8)

			local fwd = ang:Forward()

			local particle = emitter:Add("particle/smokestack", pos + fwd * 8)
			particle:SetVelocity(fwd * math.Rand(48, 64))
			particle:SetDieTime(math.Rand(1.25, 2))
			particle:SetStartAlpha(240)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(math.Rand(20, 26))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetColor(60, 60, 60)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetAirResistance(5)
		end

		emitter:Finish()
	end
end

function ENT:DoDrawing()
	local teamid = self:GetTeam()
	if MySelf:IsValid() and MySelf:Team() == teamid then
		render.SuppressEngineLighting(true)
		if MySelf == self:GetRevivePlayer() then
			local brightness = 0.3 + math.max(0, math.sin(CurTime() * 6)) * 0.4
			render.SetColorModulation(brightness, 1, brightness)
		else
			render.SetColorModulation(0.4, 1, 0.4)
		end
		self:DrawModel()
		render.SuppressEngineLighting(false)
	else
		local col = team.GetColor(teamid) or color_white
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
		self:DrawModel()
	end

	render.SetColorModulation(1, 1, 1)

	if self:GetAutoSpawnTime() ~= 0 and EyePos():Distance(self:GetPos()) <= 1024 then
		local delta = self:GetAutoSpawnTime() - CurTime()
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 270)
		cam.Start3D2D(self:GetPos() + self:GetUp() * 8 + self:GetForward() * 5, ang, 0.1 + delta % 1 * 0.025)
			draw_WordBox(0, 0, string.format("%.2d", math.max(0, math.ceil(delta))), "ass64", COLOR_TEXTYELLOW)
		cam.End3D2D()
	end
end

function ENT:Draw()
	local deltapower = self:GetDeltaPower()
	if deltapower == 0 then
		self:DoDrawing()
		return
	end

	local deltapower2 = (1 - deltapower) ^ 2

	cam.Start3D(EyePos() - Vector(0, 0, deltapower2 * 1024), EyeAngles())
		render.SetBlend(1 - deltapower2)
			self:DoDrawing()
		render.SetBlend(1)
	cam.End3D()
end

function TombSetAutoSpawnTime(time)
	local tomb = MySelf:GetTomb()
	if tomb and tomb:IsValid() and tomb.SetAutoSpawnTime then
		tomb:SetAutoSpawnTime(time)
	end
end
