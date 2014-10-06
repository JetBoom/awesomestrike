function EFFECT:Think()
	return CurTime() <= self.DieTime
end

local matRing = Material("effects/select_ring")
function EFFECT:Render()
	local ct = CurTime()
	if ct <= self.DieTime then
		local delta = self.DieTime - ct

		render.SetMaterial(matRing)
		local size = math.min((0.6 - delta) * 1400, 700)
		local alpha = math.min(255, delta * 500)
		local col = Color(255, 180, 5, alpha)
		render.DrawQuadEasy(self.Pos, self.Norm, size, size, col, 0)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col, 0)
		local col2 = Color(255, 255, 255, alpha * 0.5)
		render.DrawQuadEasy(self.Pos, self.Norm, size, size, col2, 0)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col2, 0)

		self.Entity:SetColor(col)
		local ang = self.Entity:GetAngles()
		ang:RotateAroundAxis(ang:Up(), FrameTime() * -600)
		self.Entity:SetAngles(ang)
		self.Entity:SetModelScaleVector(Vector(1 + delta * 4, 1 + delta * 4, 4 - delta * 7))
		self.Entity:DrawModel()
	end
end

local rockmodels = {"models/props_wasteland/rockcliff01b.mdl",
"models/props_wasteland/rockcliff01c.mdl",
"models/props_wasteland/rockcliff01e.mdl",
"models/props_wasteland/rockcliff01g.mdl"}

function EFFECT:Init(data)
	local normal = data:GetNormal()
	local pos = data:GetOrigin()
	self.DieTime = CurTime() + 0.6
	util.Decal("FadingScorch", pos + normal, pos - normal)
	pos = pos + normal * 3
	self.Pos = pos
	self.Norm = normal
	self.Entity:SetRenderBoundsWS(pos + Vector(-400, -400, -400), pos + Vector(400, 400, 400))

	sound.Play("ambient/explosions/explode_"..math.random(1,4)..".wav", pos, 75, math.Rand(90, 105))

	local dlight = DynamicLight(self.Entity:EntIndex())
	if dlight then
		dlight.Pos = pos + normal * 32
		dlight.r = 255
		dlight.g = 230
		dlight.b = 30
		dlight.Brightness = 5
		dlight.Decay = 800
		dlight.Size = 650
		dlight.DieTime = self.DieTime + 0.5
	end

	self.Entity:SetModel(rockmodels[math.random(1, #rockmodels)])
	local ang = normal:Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	self.Entity:SetAngles(ang)
	self.Entity:SetMaterial("models/shiny")
	self.Entity:SetColor(Color(255, 200, 0, 200))

	local ang = normal:Angle()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(36, 46)
	for i=1, 360, 3 do
		ang:RotateAroundAxis(ang:Forward(), 3)
		local dir = ang:Up()

		local particle = emitter:Add("effects/fire_cloud1", pos + dir * 8)
		particle:SetVelocity(dir * 5000)
		particle:SetDieTime(1)
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetAirResistance(1800)
	end

	emitter:Finish()
end
