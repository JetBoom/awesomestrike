function GM:ShouldDrawVirtualEntity(pl, ent)
	return pl:GetState() ~= STATE_LIGHTBENDING
end

function STATE:IsIdle(pl)
	return true
end

function STATE:SetPlayerTransparency(pl, blend)
	local col = pl:GetColor()
	col.a = math.max(1, blend * 255)
	pl:SetColor(col)
end

function STATE:Started(pl, oldstate)
	pl:DrawShadow(false)

	self:SetPlayerTransparency(pl, 0.01)

	if SERVER then
		pl:DrawWorldModel(false)
		pl:SetEnergy(pl:GetEnergy() - 10, -5, true)
		pl:EmitSound("npc/scanner/scanner_nearmiss2.wav", 60, 80)
	end
end

function STATE:Ended(pl, newstate)
	pl:SetEnergyRegeneration(ENERGY_DEFAULT_REGENERATION, true)
	pl:DrawShadow(true)

	self:SetPlayerTransparency(pl, 1)

	if SERVER then
		pl:DrawWorldModel(true)
		pl:EmitSound("npc/roller/mine/combine_mine_deploy1.wav", 60, 100)
	end
end

if SERVER then
function STATE:Think(pl)
	if pl:GetEnergy() <= 0 or not pl:IsIdle() or pl:KeyDown(IN_ATTACK) or pl:KeyDown(IN_ATTACK2) then
		pl:EndState()

		if self:GetTimeVisibility(pl) == 1 then
			pl.LastFullCloak = CurTime()
		end
	end
end

function STATE:WeaponDeployed(pl, wep)
	pl:DrawWorldModel(false)
end
end

function STATE:GetTimeVisibility(pl)
	return (1 - math.min(1, (CurTime() - pl:GetStateStart()) * 0.33))
end

if not CLIENT then return end

function STATE:GetVisibility(pl)
	return math.Clamp(self:GetTimeVisibility(pl) + pl:GetVelocity():Length() * 0.0015, 0, 1)
end

function STATE:SkipTargetID(pl)
	return pl:Team() ~= MySelf:Team() and MySelf:GetObserverMode() == OBS_MODE_NONE
end

local texCircle = surface.GetTextureID("awesomestrike/simplecircle")
function STATE:HUDPaint(pl, screenscale)
	local x, y = w * 0.5, h * 0.65
	local wid = 48 * screenscale
	local viswid = self:GetVisibility(pl) * wid

	surface.SetTexture(texCircle)
	surface.SetDrawColor(10, 10, 10, 120)
	surface.DrawTexturedRectRotated(x, y, wid, wid, 0)
	surface.SetDrawColor(255, 177, 0, 120)
	surface.DrawTexturedRectRotated(x, y, viswid, viswid, 0)
end

local vis = 1
local matRefract = Material("models/spawn_effect")
local matWhite = Material("models/debug/debugwhite")
function STATE:PrePlayerDraw(pl)
	pl:RemoveAllDecals()

	vis = self:GetVisibility(pl)
	local blend = vis ^ 2

	self:SetPlayerTransparency(pl, blend)
	render.SetBlend(blend)

	if blend < 0.2 then
		render.MaterialOverride(matWhite)
		local colmod = blend * 2
		render.SetColorModulation(colmod, colmod, colmod)
	end
end

function STATE:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)

	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", math.max(vis * 0.025, 0.0005))

	pl.SkipDrawHooks = true
	render.MaterialOverride(matRefract)
	pl:DrawModel()
	render.MaterialOverride()
	pl.SkipDrawHooks = false
end

function STATE:PreDrawViewModel(pl, viewmodel)
	if viewmodel.SkipDrawHooks then return end

	render.SetBlend(self:GetVisibility(pl) ^ 2)
end

function STATE:PostDrawViewModel(pl, viewmodel)
	if viewmodel.SkipDrawHooks then return end

	render.SetBlend(1)

	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", math.max(vis * 0.025, 0.0005))

	viewmodel.SkipDrawHooks = true
	render.MaterialOverride(matRefract)
	viewmodel:DrawModel()
	render.MaterialOverride()
	viewmodel.SkipDrawHooks = false
end

function STATE:ShouldDrawFadeTrail(pl)
	return false
end
