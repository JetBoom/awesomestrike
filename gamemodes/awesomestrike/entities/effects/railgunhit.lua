EFFECT.LifeTime = 0.5
EFFECT.LightningLifeTime = 1
EFFECT.LightningDistance = 150

function EFFECT:GetDelta()
	return math.Clamp(self.DieTime - CurTime(), 0, self.LifeTime) / self.LifeTime
end

function EFFECT:GetLightningDelta()
	return math.Clamp(self.LightningDieTime - CurTime(), 0, self.LightningLifeTime) / self.LightningLifeTime
end

function EFFECT:Think()
	return CurTime() < self.LightningDieTime
end

function EFFECT:AttachToMuzzle()
	local ent = self.Ent
	if ent:IsValid() and ent:IsPlayer() then
		local wep = ent == MySelf and not ent:ShouldDrawLocalPlayer() and ent:GetViewModel() or ent:GetActiveWeapon()
		if wep:IsValid() then
			local attach = wep:GetAttachment(1)
			if attach then
				self.StartPos = attach.Pos
			end
		end
	end

	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos, Vector(128, 128, 128))
end

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.HitNormal = data:GetNormal() * -1
	self.Ent = data:GetEntity()
	self.Magnitude = data:GetMagnitude()
	self.Color = team.GetColor(math.Round(data:GetScale())) or color_white
	self.LifeTime = 0.25 + self.Magnitude * 0.25
	self.LightningLifeTime = self.LifeTime * 4 + 0.25
	self.DieTime = CurTime() + self.LifeTime
	self.LightningDieTime = CurTime() + self.LightningLifeTime

	self:AttachToMuzzle()

	sound.Play("npc/strider/fire.wav", self.EndPos, 75 + self.Magnitude * 10, 200 - self.Magnitude * 100)

	local emitter = ParticleEmitter(self.EndPos)
	emitter:SetNearClip(24, 32)

	local r, g, b = self.Color.r, self.Color.g, self.Color.b
	local randmin, randmax = -16 + self.Magnitude * -16, self.Magnitude * 16 + 16
	local normal = (self.EndPos - self.StartPos)
	normal:Normalize()
	for i = -100, self.EndPos:Distance(self.StartPos), 6 do
		local pos = self.StartPos + normal * i + VectorRand():GetNormalized() * math.Rand(randmin, randmax)
		local dietime = self.LightningLifeTime * math.Rand(0.75, 1.5)
		local startsize = 1 + self.Magnitude * math.Rand(0.5, 2)
		local rolldelta = math.Rand(-16, 16)
		local roll = math.Rand(0, 360)
		local vel = math.Rand(192, 256) * normal

		local particle = emitter:Add("effects/spark", pos)
		particle:SetDieTime(dietime)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(startsize)
		particle:SetRoll(roll)
		particle:SetRollDelta(rolldelta)
		particle:SetVelocity(vel)
		particle:SetAirResistance(20)
		particle:SetColor(r, g, b)

		particle = emitter:Add("effects/spark", pos)
		particle:SetDieTime(dietime)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(startsize * 0.5)
		particle:SetRoll(roll)
		particle:SetRollDelta(rolldelta)
		particle:SetVelocity(vel)
		particle:SetAirResistance(20)
	end

	self.QuadPos = self.EndPos + self.HitNormal

	for i=1, 32 + self.Magnitude * 128 do
		local dir = (self.HitNormal + VectorRand():GetNormalized()) / 2

		local particle = emitter:Add("effects/rollerglow", self.QuadPos + dir)
		particle:SetVelocity((self.Magnitude * math.Rand(64, 92) + 32) * dir)
		particle:SetDieTime(0.5 + self.LightningLifeTime * math.Rand(1, 1.5))
		particle:SetStartSize(1)
		particle:SetEndSize(4 + self.Magnitude * 8)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetAirResistance(8)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(r, g, b)
	end

	emitter:Finish()

	self.NextBuildLightning = 0
	self:BuildLightning()

	local dlight = DynamicLight(0)
	if dlight then
		dlight.Pos = self.EndPos
		dlight.r = r
		dlight.g = g
		dlight.b = b
		dlight.Brightness = 2 + self.Magnitude * 2
		local size = 128 + self.Magnitude * 256
		dlight.Size = size
		dlight.Decay = size * 2
		dlight.DieTime = CurTime() + 1
	end
end

function EFFECT:BuildLightning()
	self.Lightning = {}

	local normal = (self.EndPos - self.StartPos)
	normal:Normalize()
	local dist = self.EndPos:Distance(self.StartPos)
	local baseup = 8 + self.Magnitude * 8
	for i=1, dist / self.LightningDistance do
		local startpos = self.StartPos + normal * math.Rand(0, dist)
		local ang = normal:Angle()
		ang:RotateAroundAxis(ang:Forward(), math.Rand(0, 360))
		local tab = {}
		local points = math.random(12, 16)
		local advancedist = self.LightningDistance / points
		local randdist = math.Rand(1, 2)
		for i=1, points do
			ang:RotateAroundAxis(ang:Forward(), math.Rand(-25, 25))
			table.insert(tab, startpos + randdist * baseup * ang:Up())
			startpos = startpos + advancedist * math.Rand(0.75, 1.25) * normal
		end

		table.insert(self.Lightning, tab)
	end
end

local matBeam = Material("Effects/laser1")
local matGlow = Material("effects/rollerglow")
function EFFECT:Render()
	if CurTime() >= self.NextBuildLightning then
		self.NextBuildLightning = CurTime() + math.Rand(0, 0.1)
		self:BuildLightning()
	end

	render.SetMaterial(matBeam)

	local lightningdelta = self:GetLightningDelta()
	local magnitude = lightningdelta * (self.Magnitude * 0.9 + 0.1) * 4 + 4
	for _, lightning in pairs(self.Lightning) do
		render.StartBeam(#lightning)
		for i, point in ipairs(lightning) do
			render.AddBeam(point, lightningdelta * magnitude * 0.5, 0, color_white)
		end
		render.EndBeam()
		render.StartBeam(#lightning)
		for i, point in ipairs(lightning) do
			render.AddBeam(point, lightningdelta * magnitude, 0, self.Color)
		end
		render.EndBeam()
	end

	local delta = self:GetDelta()
	if delta <= 0 then return end

	local size = delta * (12 + self.Magnitude * 25)
	render.DrawBeam(self.StartPos, self.EndPos, size * 0.5, 1, 0, color_white)
	render.DrawBeam(self.StartPos, self.EndPos, size, 1, 0, self.Color)

	local size2 = size * 12
	local size3 = size * 6
	render.SetMaterial(matGlow)
	render.DrawSprite(self.QuadPos, size3, size3, color_white)
	render.DrawSprite(self.QuadPos, size2, size2, self.Color)
	render.DrawQuadEasy(self.QuadPos, self.HitNormal, size3, size3, color_white)
	render.DrawQuadEasy(self.QuadPos, self.HitNormal * -1, size3, size3, color_white)
	render.DrawQuadEasy(self.QuadPos, self.HitNormal, size2, size2, self.Color)
	render.DrawQuadEasy(self.QuadPos, self.HitNormal * -1, size2, size2, self.Color)
end
