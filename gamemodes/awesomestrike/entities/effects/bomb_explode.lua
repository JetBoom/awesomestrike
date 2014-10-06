util.PrecacheSound("awesomestrike/bombexplode.wav")

local colormod = {
	["$pp_colour_contrast"] = 1,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_colour"] = 1,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local renderstart, renderend, renderpos
local function BombRenderScreenspaceEffects()
	if CurTime() >= renderend then
		hook.Remove("RenderScreenspaceEffects", "BombRenderScreenspaceEffects")
		return
	end

	if render.GetDXLevel() < 80 then return end

	local fadein = math.Clamp(math.min((renderend - CurTime()) * 0.2, (CurTime() - renderstart) * 0.5), 0, 1)

	colormod["$pp_colour_contrast"] = 1 + fadein
	colormod["$pp_colour_brightness"] = fadein * 0.75
	colormod["$pp_colour_colour"] = 1 - fadein * 0.5
	DrawColorModify(colormod)
end

function EFFECT:Init(data)
	self.StartTime = CurTime()
	self.DieTime = self.StartTime + 6

	local pos = data:GetOrigin()

	self.Pos = pos

	sound.Play("awesomestrike/bombexplode.wav", pos, 100, 100)
	sound.Play("npc/combine_gunship/gunship_explode2.wav", pos, 95, 90)
	sound.Play("npc/combine_gunship/gunship_explode2.wav", pos, 95, 90)

	local tr = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, -32), mask = MASK_SOLID_BRUSHONLY})
	util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(48, 64)
	for i=1, 359 do
		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(Vector(1400 * math.sin(i), 1400 * math.cos(i), 0))
		particle:SetDieTime(8)
		particle:SetStartAlpha(100)
		particle:SetEndAlpha(0)
		particle:SetStartSize(160)
		particle:SetEndSize(500)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(20)
	end

	for i=1, 5 do
		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(3 + i)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(300)
		particle:SetEndSize(7500)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
	end

	for i=1, 128 do
		local particle = emitter:Add("particle/smokestack", pos + VectorRand():GetNormalized() * math.Rand(64, 512))
		particle:SetVelocity(VectorRand():GetNormalized() * 256)
		particle:SetDieTime(math.Rand(12, 14))
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(128, 256))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetColor(30, 30, 30)
		particle:SetAirResistance(30)
	end

	emitter:Finish()

	self.Entity:SetModel("models/hunter/misc/sphere1x1.mdl")
	self.Entity:SetMaterial("models/debug/debugwhite")
	self.Entity:SetRenderBoundsWS(pos + Vector(-8000, -8000, -8000), pos + Vector(8000, 8000, 8000))

	renderstart = self.StartTime
	renderend = self.DieTime
	renderpos = pos
	hook.Add("RenderScreenspaceEffects", "BombRenderScreenspaceEffects", BombRenderScreenspaceEffects)
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matCharge = Material("sprites/glow04_noz")
local matRefract = Material("models/spawn_effect")
function EFFECT:Render()
	local fadein = math.min((CurTime() - self.StartTime) * 0.3, 1)
	local siz = fadein * 80
	local ent = self.Entity

	if render.GetDXLevel() >= 80 then
		render.UpdateRefractTexture()

		matRefract:SetFloat("$refractamount", math.Clamp(math.min((renderend - CurTime()) * 0.2, (CurTime() - renderstart) * 0.5), 0, 1) * 0.025)

		render.MaterialOverride(matRefract)
	else
		ent:SetAngles(Angle(0, (CurTime() * 360) % 360, 0))
		ent:SetColor(Color(255, 255, 255, fadein * 128))
	end

	ent:SetModelScale(siz * -1, 0)
	ent:DrawModel()
	ent:SetModelScale(siz, 0)
	ent:DrawModel()
	render.MaterialOverride()

	render.SetMaterial(matCharge)
	render.DrawSprite(self.Pos, siz * 70, siz * 70, color_white)
	render.DrawSprite(self.Pos, siz * 90, siz * 90, color_white)
	render.DrawSprite(self.Pos, siz * 120, siz * 120, color_white)
end
