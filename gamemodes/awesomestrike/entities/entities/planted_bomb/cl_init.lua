include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

util.PrecacheSound("weapons/c4/c4_click.wav")

function ENT:Initialize()
	self.LastBeep = CurTime()
	self.NextBeep = 0

	self.Death = CurTime() + 45
end

function ENT:Think()
	if self.NextBeep <= CurTime() then
		self:EmitSound("weapons/c4/c4_click.wav", 80, 100)

		self.LastBeep = CurTime()
		self.NextBeep = self.LastBeep + math.max(0.15, (((self:GetBombTime() - CurTime()) / 60) ^ 0.75) * 2)

		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = self:GetPos() + self:GetUp() * 9
			dlight.r = 255
			dlight.g = 10
			dlight.b = 10
			dlight.Brightness = 1
			dlight.Size = 64
			dlight.Decay = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

local matWhite = Material("models/debug/debugwhite")
local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	render.SuppressEngineLighting(true)
	render.SetColorModulation(1, 0.1, 0.1)
		self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)

	local size = math.Clamp((1 - (CurTime() - self.LastBeep) * 8), 0, 1) * 48
	if size > 0 then
		render.SetMaterial(matGlow)
		render.DrawSprite(self:GetPos() + self:GetUp() * 9, size, size, COLOR_RED)
	end
end
