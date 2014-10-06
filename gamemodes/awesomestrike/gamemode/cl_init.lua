include("cl_boneanimlib.lua")
include("cl_animeditor.lua")

include("shared.lua")

include("obj_entity_extend_cl.lua")
include("obj_player_extend_cl.lua")

include("cl_deathnotice.lua")
include("cl_notice.lua")
include("cl_targetid.lua")
include("cl_dermaskin.lua")
include("cl_scoreboard.lua")
include("cl_radio.lua")

include("vgui/dmodelpanel2.lua")
include("vgui/dweaponicon.lua")
include("vgui/dweaponstats.lua")
include("vgui/dskillicon.lua")
include("vgui/dskillstats.lua")
include("vgui/dsplash.lua")
include("vgui/pbuymenu.lua")
include("vgui/pteams.lua")
include("vgui/phelp.lua")
include("vgui/pcharacter.lua")

function BetterScreenScale()
	return math.max(0.6, math.min(1, ScrH() / 1080))
end

function WordBox(parent, text, font, textcolor)
	local cpanel = vgui.Create("DPanel", parent)
	local label = EasyLabel(cpanel, text, font, textcolor)
	local tsizex, tsizey = label:GetSize()
	cpanel:SetSize(tsizex + 16, tsizey + 8)
	label:SetPos(8, (tsizey + 8) * 0.5 - tsizey * 0.5)
	cpanel:SetVisible(true)
	cpanel:SetMouseInputEnabled(false)
	cpanel:SetKeyboardInputEnabled(false)

	return cpanel
end

function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "DefaultFont")
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end

COLOR_RED = Color(255, 0, 0)
COLOR_YELLOW = Color(255, 255, 0)
COLOR_ORANGE = Color(255, 200, 0)
COLOR_PINK = Color(255, 20, 100)
COLOR_GREEN = Color(0, 255, 0)
COLOR_LIMEGREEN = Color(50, 255, 50)
COLOR_PURPLE = Color(255, 0, 255)
COLOR_BLUE = Color(0, 0, 255)
COLOR_CYAN = Color(0, 255, 255)
COLOR_WHITE = Color(255, 255, 255)
COLOR_BLACK = Color(0, 0, 0)
COLOR_TEXTYELLOW = Color(255, 177, 0)
COLOR_LINEYELLOW = Color(95, 56, 0)
COLOR_LIGHTBLUE = Color(0, 60, 255)

color_black_alpha90 = Color(0, 0, 0, 90)
color_black_alpha120 = Color(0, 0, 0, 120)
color_black_alpha180 = Color(0, 0, 0, 180)
color_black_alpha220 = Color(0, 0, 0, 220)

CreateClientConVar("awesomestrike_skill", 1, true, true)
CreateClientConVar("awesomestrike_weapon1", 1, true, true)
CreateClientConVar("awesomestrike_weapon2", 13, true, true)
CreateClientConVar("awesomestrike_weapon3", 17, true, true)

MySelf = MySelf or NULL
hook.Add("InitPostEntity", "GetLocal", function()
	MySelf = LocalPlayer()

	GAMEMODE.HookGetLocal = GAMEMODE.HookGetLocal or (function(g) end)
	gamemode.Call("HookGetLocal", MySelf)
	RunConsoleCommand("initpostentity")
end)

function GM:HookGetLocal(pl)
	pl.NextDodge = 0
	pl.NextAirDodge = 0
	pl.NextWallJump = 0

	pl:SetEnergy(ENERGY_DEFAULT, ENERGY_DEFAULT_REGENERATION)
	pl:SetCombo(0)

	self.RenderScreenspaceEffects = self._RenderScreenspaceEffects
	self.CreateMove = self._CreateMove
	self.AdjustMouseSensitivity = self._AdjustMouseSensitivity
	self.HUDShouldDraw = self._HUDShouldDraw
	self.PostDrawOpaqueRenderables = self._PostDrawOpaqueRenderables
	self.Think = self._Think
	self.PrePlayerDraw = self._PrePlayerDraw
	self.PostPlayerDraw = self._PostPlayerDraw
	self.ShouldDrawLocalPlayer = self._ShouldDrawLocalPlayer
end

local trailpower = 0
local colSprite = Color(255, 255, 255, 90)
local spritepositions = {}
local nextsprite = 0
local matSprite = Material("trails/laser")
local function GenerateTrail()
	table.insert(spritepositions, Vector(64, math.random(2) == 1 and math.Rand(-16, -4) or math.Rand(4, 16), math.random(2) == 1 and math.Rand(-16, -4) or math.Rand(4, 16)))
end
for i=1, 32 do
	GenerateTrail()
end
function GM:DrawSpeedTrails()
	local ent = MySelf:CallStateFunction("DrawSpeedTrailEntity") or MySelf
	local eyeangles = EyeAngles()
	local eyeforward = eyeangles:Forward()
	local vel = ent:GetVelocity()
	local speed = vel:Length() * vel:GetNormalized():Dot(eyeforward)
	if speed >= 300 then
		trailpower = math.Approach(trailpower, 1, FrameTime() * 2)
	elseif trailpower > 0 then
		trailpower = math.Approach(trailpower, 0, FrameTime() * 4)
	else
		return
	end

	if CurTime() >= nextsprite and #spritepositions < 32 then
		nextsprite = CurTime() + 0.1
		GenerateTrail()
	end

	local basealpha = trailpower * 90

	local eyepos = EyePos()
	local eyeup = eyeangles:Up()
	local eyeright = eyeangles:Right()
	local veloffset = eyeforward * -32

	local time = FrameTime() * speed * 0.1
	render.SetMaterial(matSprite)
	for _, pos in pairs(spritepositions) do
		pos.x = pos.x - time
		local drawpos = eyepos + eyeforward * pos.x + eyeright * pos.y + eyeup * pos.z
		colSprite.a = basealpha * math.Clamp(1 - pos.x / 40, 0, 1)
		render.DrawBeam(drawpos, drawpos + veloffset, 0.5, 0, 0, colSprite)
	end

	for k=1, #spritepositions do
		local v = spritepositions[k]
		if v and v.x < 0 then
			table.remove(spritepositions, k)
			k = k - 1
		end
	end
end

function GM:_PostDrawOpaqueRenderables()
	self:DrawSpeedTrails()
end

function GM:Draw3DHUD()
	if not MySelf:Alive() then return end

	local screenscale = BetterScreenScale()

	self:DrawHealth3D(screenscale)
	self:DrawAmmo3D(screenscale)
end

function GM:Get3D2DScreenPos(x, y)
	local pos = EyePos()
	local ang = EyeAngles()
	local forward = ang:Forward()
	local right = ang:Right()
	local up = ang:Up()
	ang:RotateAroundAxis(forward, 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local fovscale = 90 / self.FOV

	pos = pos + fovscale * 32 * forward + y * 16 * up + x * 16 * right

	return pos, ang
end

function GM:_ShouldDrawLocalPlayer(pl)
	if pl:GetActiveWeapon().ForceThirdPerson or pl:CallStateFunction("ShouldDrawLocalPlayer") or pl:IsPlayingTaunt() then return true end

	return false
end

function GM:SpawnMenuEnabled()
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:ContextMenuOpen()
	return false
end

function GM:HUDWeaponPickedUp(wep)
end

function GM:HUDItemPickedUp(itemname)
end

function GM:HUDAmmoPickedUp(itemname, amount)
end

GM.WeaponBindSlots = {
	"weapon_as_smg",
	"weapon_as_smg",
	"weapon_as_smg"
}

net.Receive("as_weaponbindslots", function(length)
	GAMEMODE.WeaponBindSlots[1] = net.ReadString()
	GAMEMODE.WeaponBindSlots[2] = net.ReadString()
	GAMEMODE.WeaponBindSlots[3] = net.ReadString()
end)

function GM:SelectWeaponSlot(slot)
	if slot >= 1 and slot <= 3 then
		--[[local buyable = self:GetBuyable(MySelf, GetConVarNumber("awesomestrike_weapon"..slot))
		if buyable then
			self:QueueWeaponSelection(buyable.SWEP)
		end]]
		self:QueueWeaponSelection(self.WeaponBindSlots[slot])
	else
		for _, wep in pairs(MySelf:GetWeapons()) do
			if wep.Slot + 1 == slot then
				self:QueueWeaponSelection(wep:GetClass())
				break
			end
		end
	end
end

function GM:SpectatorKeyPress(pl, key)
	if key == IN_DUCK and IsFirstTimePredicted() then
		self.LockedChaseCam = not self.LockedChaseCam
	end
end

function GM:SpectatorBindPress(pl, bind, down)
	if string.sub(bind, 1, 4) == "slot" then
		local index = tonumber(string.sub(bind, 5))
		if index then
			RunConsoleCommand("setspectatorslot", index)
		end
	end
end

function GM:PlayerBindPress(pl, bind, down)
	if not down then return end

	if pl:GetObserverMode() ~= OBS_MODE_NONE then
		return self:SpectatorBindPress(pl, bind, down)
	end

	if bind == "+menu" then
		RunConsoleCommand("dropweapon")
		return true
	elseif string.sub(bind, 1, 4) == "slot" then
		local id = tonumber(string.sub(bind, 5))
		if id then
			self:SelectWeaponSlot(id)
			return true
		end
	end
end

function BetterScreenScale()
	return math.Clamp(ScrH() / 1080, 0.6, 1)
end

function GM:Initialize()
	self.BaseClass:Initialize()

	self:CreateFonts()
	self:AddParticles()

	timer.SimpleEx(15, self.AddNotice, self, "Welcome to Awesome Strike!", 15)
	timer.SimpleEx(16, self.AddNotice, self, "Press F1 for controls and other help.", 15)
	timer.SimpleEx(17, self.AddNotice, self, "Please report any bugs you encounter.", 15)
	timer.SimpleEx(18, self.AddNotice, self, "Submit suggestions at noxiousnet.com/forums", 15)
end

function surface.CreateLegacyFont(font, size, weight, antialias, additive, name, shadow, outline, blursize)
	surface.CreateFont(name, {font = font, size = size, weight = weight, antialias = antialias, additive = additive, shadow = shadow, outline = outline, blursize = blursize})
end

function GM:CreateFonts()
	surface.CreateLegacyFont("hidden", 14, 400, true, false, "ass14")
	surface.CreateLegacyFont("hidden", 16, 400, true, false, "ass16")
	surface.CreateLegacyFont("hidden", 24, 400, true, false, "ass24")
	surface.CreateLegacyFont("hidden", 32, 400, true, false, "ass32")
	surface.CreateLegacyFont("hidden", 64, 400, true, false, "ass64")
	surface.CreateLegacyFont("hidden", 14, 400, true, false, "ass14_shadow", false, true)
	surface.CreateLegacyFont("hidden", 16, 400, true, false, "ass16_shadow", false, true)
	surface.CreateLegacyFont("hidden", 24, 400, true, false, "ass24_shadow", false, true)
	surface.CreateLegacyFont("hidden", 64, 400, true, false, "ass64_shadow", false, true)
	surface.CreateLegacyFont("hidden", 72, 400, true, false, "ass72_shadow", false, true)

	local screenscale = BetterScreenScale()

	surface.CreateLegacyFont("Counter-Strike", screenscale * 32, 400, true, false, "ass_icons")
	surface.CreateLegacyFont("Counter-Strike", screenscale * 32, 400, true, false, "ass_icons_shadow", false, true)
	surface.CreateLegacyFont("Counter-Strike", screenscale * 64, 400, true, false, "ass_biggest_icons")
	surface.CreateLegacyFont("Counter-Strike", screenscale * 64, 400, true, false, "ass_biggest_icons_shadow", false, true)

	surface.CreateLegacyFont("hidden", 12, 400, true, false, "ass_tiny")
	surface.CreateLegacyFont("hidden", 12, 400, true, false, "ass_tiny_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 14, 400, true, false, "ass_smallest")
	surface.CreateLegacyFont("hidden", screenscale * 14, 400, true, false, "ass_smallest_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 16, 400, true, false, "ass_smaller")
	surface.CreateLegacyFont("hidden", screenscale * 16, 400, true, false, "ass_smaller_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 24, 400, true, false, "ass_small")
	surface.CreateLegacyFont("hidden", screenscale * 24, 400, true, false, "ass_small_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 32, 400, true, false, "ass")
	surface.CreateLegacyFont("hidden", screenscale * 32, 400, true, false, "ass_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 40, 400, true, false, "ass_big")
	surface.CreateLegacyFont("hidden", screenscale * 40, 400, true, false, "ass_big_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 48, 400, true, false, "ass_bigger")
	surface.CreateLegacyFont("hidden", screenscale * 48, 400, true, false, "ass_bigger_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 64, 400, true, false, "ass_biggest")
	surface.CreateLegacyFont("hidden", screenscale * 64, 400, true, false, "ass_biggest_shadow", false, true)
	surface.CreateLegacyFont("hidden", screenscale * 72, 400, true, false, "ass_giant")
	surface.CreateLegacyFont("hidden", screenscale * 72, 400, true, false, "ass_giant_shadow", false, true)

	surface.CreateFont("DefaultFontVerySmall", {font = "tahoma", size = 10, weight = 0, antialias = false})
	surface.CreateFont("DefaultFontSmall", {font = "tahoma", size = 11, weight = 0, antialias = false})
	surface.CreateFont("DefaultFontSmallDropShadow", {font = "tahoma", size = 11, weight = 0, shadow = true, antialias = false})
	surface.CreateFont("DefaultFont", {font = "tahoma", size = 13, weight = 500, antialias = false})
	surface.CreateFont("DefaultFontBold", {font = "tahoma", size = 13, weight = 1000, antialias = false})
	surface.CreateFont("DefaultFontLarge", {font = "tahoma", size = 16, weight = 0, antialias = false})
end

function GM:InitPostEntity()
end

function GM:WeaponDeployed(pl, wep)
	pl:CallStateFunction("WeaponDeployed", wep)
	pl:CallSkillFunction("WeaponDeployed", wep)
end

function GM:QueueWeaponSelection(swepclass)
	RunConsoleCommand("use", swepclass)

	self.QueuedWeapon = swepclass
	self.QueuedWeaponTime = CurTime() + 5
end

function GM:_Think()
	for _, pl in pairs(player.GetAll()) do
		pl:SetIK(false)

		pl:Think()
	end

	if self.QueuedWeapon then
		RunConsoleCommand("use", self.QueuedWeapon)

		local wep = MySelf:GetActiveWeapon()
		if self.QueuedWeaponTime and CurTime() >= self.QueuedWeaponTime or wep and wep:IsValid() and wep:GetClass() == self.QueuedWeapon then
			self.QueuedWeapon = nil
			self.QueuedWeaponTime = nil
		end
	end
end

function GM:_CreateMove(cmd)
	if MySelf:IsPlayingTaunt() and MySelf:Alive() then
		self:CreateMoveTaunt(cmd)
	end

	return MySelf:CallStateFunction("CreateMove", cmd) or self.BaseClass.CreateMove(self, cmd)
end

function GM:CreateMoveTaunt(cmd)
	cmd:ClearButtons(0)
	cmd:ClearMovement()
end

local matCircle = Material("SGM/playercircle")
local colRing = Color(10, 255, 10, 60)
local vecUp = Vector(0, 0, 1)
local vecDown = Vector(0, 0, -1)
function GM:DrawTeamRing(pl)
	local pos = pl:GetPos() + vecUp

	render.SetMaterial(matCircle)
	render.DrawQuadEasy(pos, vecUp, 32, 32, colRing)
	render.DrawQuadEasy(pos, vecDown, 32, 32, colRing)
end

function GM:_PrePlayerDraw(pl)
	if not pl.SkipDrawHooks then
		if not pl.FadeTrailAmount then pl.FadeTrailAmount = 0 end
		if pl:CallStateFunction("ShouldDrawFadeTrail") then
			pl.FadeTrailAmount = math.Approach(pl.FadeTrailAmount, 1, FrameTime() * 5)
		else
			local speed = pl:GetVelocity():Length()
			if speed > 450 then
				pl.FadeTrailAmount = math.Approach(pl.FadeTrailAmount, math.min(1, (speed - 450) * 0.005), FrameTime() * 5)
			elseif pl.FadeTrailAmount > 0 then
				pl.FadeTrailAmount = math.Approach(pl.FadeTrailAmount, 0, FrameTime())
			end
		end

		if not pl.WallRunAmount then pl.WallRunAmount = 0 end
		if pl:GetState() ~= STATE_WALLRUN and pl.WallRunAmount ~= 0 then
			pl.WallRunAmount = math.Approach(pl.WallRunAmount, 0, FrameTime() * 2)
			--if pl.WallRunAmount == 0 then
			--	pl:SetAllowFullRotation(false)
			--end
		end

		local myteam = MySelf:Team()

		if pl ~= MySelf and myteam ~= TEAM_SPECTATOR and myteam == pl:Team() and pl:Alive() then
			self:DrawTeamRing(pl)
		end

		if pl:CallStateFunction("PrePlayerDraw") then
			return true
		else
			if pl.FadeTrailAmount > 0 then
				pl:DrawFadeTrail(pl.FadeTrailAmount)
			end

			if pl.WallRunAmount ~= 0 then
				--if not pl:GetAllowFullRotation() then
					--pl:SetAllowFullRotation(true)
				--end
				local ang = pl:GetRenderAngles()
				ang.roll = CosineInterpolation(0, pl.WallRunAmount < 0 and -1 or 1, pl.WallRunAmount) * 30
				pl:SetRenderAngles(ang)
			end

			if myteam == TEAM_SPECTATOR then
				undo = true
				render.SuppressEngineLighting(true)
				local col = team.GetColor(pl:Team()) or color_white
				render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
			elseif pl ~= MySelf then
				if pl:Team() == myteam then
					undo = true
					render.SuppressEngineLighting(true)
					if myteam == TEAM_T and pl:HasWeapon("weapon_as_bomb") then
						local brit = 0.4 + math.abs(math.sin(CurTime() * 4)) * 0.2
						render.SetColorModulation(brit, 1, brit)
					else
						render.SetColorModulation(0.4, 1, 0.4)
					end
				elseif not self:MapHasObjective() and not pl:GetDiedThisRound() and (pl:CallStateFunction("GetVisibility") or 1) == 1 then
					undo = true
					render.SetColorModulation(1, 0.2, 0.2)
					if MySelf:GetDiedThisRound() then
						render.SuppressEngineLighting(true)
					end
				end
			end
		end
	end
end

local matWhite = Material("models/debug/debugwhite")
function GM:_PostPlayerDraw(pl)
	if not pl.SkipDrawHooks then
		if undo then
			undo = false
			render.SuppressEngineLighting(false)
			render.SetColorModulation(1, 1, 1)
		end

		pl:CallStateFunction("PostPlayerDraw")
	end
end

function GM:PlayerDeath(pl, attacker)
end

function GM:StartRound()
	self.StartRoundNotifyStart = CurTime()
	self.StartRoundNotifyEnd = self.StartRoundNotifyStart + 8
end

function GlowColor(col, inputcol, seed)
	local glow = math.abs(math.sin((UnPredictedCurTime() + (seed or 0)) * math.pi)) * 120
	col.r = math.min(255, inputcol.r + glow)
	col.g = math.min(255, inputcol.g + glow)
	col.b = math.min(255, inputcol.b + glow)
	return col
end

local coltemp = Color(255, 255, 255, 255)
local texCircle = surface.GetTextureID("awesomestrike/simplecircle")
local texGear = surface.GetTextureID("awesomestrike/gear2")
local CreatedFonts = {}
function draw_SuperFancyGear(x, y, wid, colinput, text, font)
	local ct = UnPredictedCurTime()
	local centerx, centery = x + wid * 0.5, y + wid * 0.5

	surface.SetTexture(texCircle)
	surface.SetDrawColor(color_black)
	surface.DrawTexturedRect(x, y, wid, wid)
	surface.SetDrawColor(colinput)
	surface.DrawTexturedRect(x + 4, y + 4, wid - 8, wid - 8)

	local gearw = wid * 0.85
	surface.SetTexture(texGear)
	surface.SetDrawColor(color_black)
	surface.DrawTexturedRectRotated(centerx, centery, gearw, gearw, ct * 90)

	if text then
		draw.SimpleText(text, font or "ass_bigger_shadow", centerx + math.sin(ct * 2) * 4, y + wid * 0.3 + math.cos(ct * 2) * 4, colinput, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function draw_WordBox(x, y, txt, font, col)
	surface.SetFont(font)
	local texw, texh = surface.GetTextSize(txt)
	local boxy = y - (texh + 6) * 0.5
	local height = texh + 6
	draw.RoundedBox(8, x - (texw + 40) * 0.5, boxy, texw + 40, height, color_black_alpha90)
	draw.SimpleText(txt, font, x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return boxy + height
end

function draw_WordBoxLeft(x, y, txt, font, col)
	surface.SetFont(font)
	local texw, texh = surface.GetTextSize(txt)
	local height = texh + 12
	draw.RoundedBox(8, x, y, texw + 20, height, color_black_alpha90)
	draw.SimpleText(txt, font, x + (texw + 20) * 0.5, y + (texh * 0.5 + 6), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return y + height
end

function GM:DrawBeacon(pos, r, g, b)
	local pos = pos:ToScreen()
	local d = CurTime() * 2 % 1
	local size = d * 64
	local hsize = size / 2
	surface.SetTexture(texCircle)
	surface.SetDrawColor(r, g, b, (1 - d) * 200)
	surface.DrawTexturedRect(pos.x - hsize, pos.y - hsize, size, size)
end

GM.ComboBonuses = {}
function GM:AddSubTypesToComboArea(subtypes)
	for _, subtype in pairs(subtypes) do
		if self.KillMessageSubTypeStrings[subtype] then
			local txt
			if self.KillAction2ExtraPoints[subtype] then
				txt = self.KillMessageSubTypeStrings[subtype] .. " (+" .. self.KillAction2ExtraPoints[subtype] .. ")"
			else
				txt = self.KillMessageSubTypeStrings[subtype]
			end
			table.insert(self.ComboBonuses, 1, {txt, CurTime() + self.ComboTime})
		end
	end
end

local colCombo = Color(255, 177, 0)
function GM:DrawCombo()
	local x = 16

	local combo = MySelf:GetCombo()
	if combo > 0 then
		local y = h * 0.5

		local fadein = math.Clamp((MySelf.ComboEndTime - CurTime()) * 0.5, 0, 1)
		colCombo.a = fadein * 255
		GlowColor(colCombo, COLOR_TEXTYELLOW)

		draw.SimpleText(combo, "ass_big_shadow", x, y, colCombo, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		local countw, counth = surface.GetTextSize(combo)
		draw.SimpleText(" COMBO!", "ass_small_shadow", x + countw, y, colCombo, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		local comment = self.ComboLevels[math.floor(combo / 5)] or combo >= 5 and self.ComboLevels[#self.ComboLevels]
		if comment then
			local texw, texh = surface.GetTextSize(" COMBO!")
			draw.SimpleText(comment, "ass_smaller_shadow", x + countw + texw - 8, y, colCombo, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		end
	end

	if #self.ComboBonuses > 0 then
		local y = h * 0.55

		local done = true

		local ct = CurTime()
		for i, tab in ipairs(self.ComboBonuses) do
			local delta = tab[2] - ct
			if delta > 0 then
				done = false

				colCombo.a = math.min(1, delta * 0.5) * 255
				draw.SimpleText(tab[1], "ass_smaller_shadow", x, y, colCombo)
				local tw, th = surface.GetTextSize(tab[1])
				y = y + th + 2
			end
		end

		if done then
			self.ComboBonuses = {}
		end
	end
end

function GM:Died(attacker)
	if attacker and attacker:IsValid() then
		self.DeathIconEnd = CurTime() + 5
		self.DeathIconName = attacker:IsPlayer() and attacker:Name() or attacker:GetClass()
	end
end

function GM:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume)
	if pl:GetStateTable().NoFootsteps or pl:GetVelocity():Length() < 135 then return true end

	return self.BaseClass.PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume)
end

function GM:PlayerStepSoundTime(pl, iType, bWalking)
	local fStepTime

	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		fStepTime = 550 - math.min(pl:GetVelocity():Length2D() * 0.8, 400)
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		fStepTime = 450 
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		fStepTime = 600
	else
		fStepTime = 350
	end

	if pl:Crouching() then
		fStepTime = fStepTime + 50
	end

	return fStepTime
end

w, h = ScrW(), ScrH()
timer.Create("UpdateResolution", 4, 0, function()
	w, h = ScrW(), ScrH()
end)

function GM:DrawUseProgress(message, progress)
	surface.SetFont("ass_big")
	local usew, useh = surface.GetTextSize(message)

	draw.RoundedBox(16, w * 0.5 - usew * 0.55, h * 0.6 - useh * 0.55, usew * 1.1, useh * 1.1 + 32, color_black_alpha180)
	draw.SimpleText(message, "ass_big", w * 0.5, (h * 0.6 - useh * 0.55) + 8, Color(255, 200, 0, 170 + math.sin(CurTime() * 6) * 135), TEXT_ALIGN_CENTER)

	local y = h * 0.6 + useh * 1.1
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(w * 0.5 - usew * 0.5, y, usew, 7)
	surface.SetDrawColor(255, 190, 0, 255)
	surface.DrawOutlinedRect(w * 0.5 - usew * 0.5, y, usew, 7)
	surface.DrawRect(w * 0.5 - usew * 0.5, y, usew * progress, 7)
end

local texCircle = surface.GetTextureID("awesomestrike/simplecircle")
function GM:DrawGameTypeHUD()
	if self:GetNumBombTargets() > 0 then
		if MySelf:Team() == TEAM_CT then
			draw_WordBoxLeft(0, 8, #ents.FindByClass("planted_bomb") > 0 and "OBJ: DEFUSE THE BOMB" or "OBJ: PREVENT BOMBING", "ass_smaller", COLOR_LIGHTBLUE)
		else
			draw_WordBoxLeft(0, 8, #ents.FindByClass("planted_bomb") > 0 and "OBJ: DEFEND THE BOMB" or "OBJ: BOMB THE TARGET", "ass_smaller", COLOR_RED)
		end
		--[[local myteam = MySelf:Team()
		local isspec = myteam == TEAM_SPECTATOR
		local y = draw_WordBoxLeft(0, 8, "OBJ: SECURE BOMB SITES", "ass_smaller", COLOR_TEXTYELLOW)
		for i, ent in ipairs(ents.FindByClass("point_capturezone")) do
			local msg
			local col = COLOR_TEXTYELLOW

			local teamid = ent:GetTeam()
			if isspec then
				if teamid > 0 then
					local cap = ent:GetCapturingTeam()
					if cap > 0 then
						msg = "CAPTURING BY "..team.GetName(teamid)
						col = CurTime() % 0.5 <= 0.25 and team.GetColor(teamid) or COLOR_TEXTYELLOW
					else
						msg = team.GetName(teamid)
						col = team.GetColor(teamid)
					end
				else
					local cap = ent:GetCapturingTeam()
					if cap > 0 then
						msg = "CAPTURING BY "..team.GetName(teamid)
						col = CurTime() % 0.5 <= 0.25 and team.GetColor(teamid) or COLOR_TEXTYELLOW
					else
						msg = "OPEN"
					end
				end
			else
				if teamid == myteam then
					if ent:GetCapturingTeam() <= 0 then
						msg = "SECURED"
						col = COLOR_LIMEGREEN
					else
						msg = "WARNING"
						col = CurTime() % 0.5 <= 0.25 and COLOR_RED or COLOR_TEXTYELLOW
					end
				elseif ent:GetCapturingTeam() == myteam then
					msg = "CAPTURING"
					col = CurTime() % 0.5 <= 0.25 and COLOR_LIMEGREEN or (teamid > 0 and COLOR_RED or COLOR_TEXTYELLOW)
				elseif teamid > 0 then
					msg = "COMPROMISED"
					col = COLOR_RED
				else
					msg = "OPEN"
					col = COLOR_TEXTYELLOW
				end
			end

			y = draw_WordBoxLeft(0, y, "SITE "..i..": "..msg, "ass_smallest", col)
		end]]
	elseif self:GetNumHostages() > 0 then
		if MySelf:Team() == TEAM_CT then
			draw_WordBoxLeft(0, 8, "OBJ: RESCUE ALL HOSTAGES", "ass_smaller", COLOR_LIGHTBLUE)
		else
			draw_WordBoxLeft(0, 8, "OBJ: PREVENT HOSTAGE RESCUE", "ass_smaller", COLOR_RED)
		end
	elseif self:GetIsCTF() then
		draw_WordBoxLeft(0, 8, "OBJ: CAPTURE THE FLAG", "ass_smaller", COLOR_TEXTYELLOW)
	else
		local y = draw_WordBoxLeft(0, 8, MySelf:GetDiedThisRound() and "OBJ: KILL HIGHLIGHTED TARGETS" or "OBJ: STAY ALIVE", "ass_smaller", COLOR_TEXTYELLOW)
		y = draw_WordBoxLeft(0, y, "REMAINING Ts: "..team.NumDidntDieThisRoundPlayers(TEAM_T), "ass_smallest", COLOR_RED)
		draw_WordBoxLeft(0, y, "REMAINING CTs: "..team.NumDidntDieThisRoundPlayers(TEAM_CT), "ass_smallest", COLOR_LIGHTBLUE)
	end
end

GM.TickTockTime = 0
function GM:TickTock(snd, pitch)
	if CurTime() >= self.TickTockTime then
		self.TickTockTime = CurTime() + 1

		MySelf:EmitSound(snd or "", 100, pitch or 100)
	end
end

function GM:HUDPaint()
	if not MySelf:IsValid() then return end

	local screenscale = BetterScreenScale()

	self:DrawDeathNotice(w - 16, 16)
	self:HUDDrawTargetID()

	self:DrawGameTypeHUD()

	MySelf:CallStateFunction("HUDPaint", screenscale)

	self:DrawNotice(screenscale)

	surface.SetFont("ass_small_shadow")
	local texw, texh = surface.GetTextSize("a")

	local x, y = w - 16 * screenscale, h * 0.5
	if CanBuy then
		draw.SimpleText("F3: Equipment", "ass_small_shadow", x, y, COLOR_LIMEGREEN, TEXT_ALIGN_RIGHT)
	end

	y = y + texh + 8
	if MySelf.CanPlantBomb then
		draw.SimpleText("BOMB SITE", "ass_small_shadow", x, y, COLOR_LIMEGREEN, TEXT_ALIGN_RIGHT)
	end

	y = y + texh + 8
	if CanRescueHostage then
		draw.SimpleText("Hostage Zone", "ass_small_shadow", x, y, COLOR_LIMEGREEN, TEXT_ALIGN_RIGHT)
	end

	local ent = MySelf:GetUseTarget()
	if ent:IsValid() and ent.UseDuration and ent:GetUsePlayer() == MySelf then
		self:DrawUseProgress(ent:GetUseMessage() or "USING", math.Clamp(ent.GetUsePercent and ent:GetUsePercent() or ((CurTime() - ent:GetUseStart()) / ent.UseDuration), 0, 1))
	end

	if not MySelf:Alive() then
		local grave = MySelf:GetTomb()
		if grave and grave:IsValid() then
			if grave:GetUsePlayer():IsValid() then
				self:DrawUseProgress("BEING REVIVED", math.Clamp(grave.GetUsePercent and grave:GetUsePercent() or ((CurTime() - grave:GetUseStart()) / grave.UseDuration), 0, 1))
			elseif grave:GetAutoSpawnTime() ~= 0 then
				draw_WordBox(w * 0.5, h * 0.75, "REVIVAL IN "..string.format("%.2d", math.max(0, math.ceil(grave:GetAutoSpawnTime() - CurTime()))), "ass_small", COLOR_TEXTYELLOW)
			end
		end

		local target = MySelf:GetObserverTarget()
		if target and target:IsValid() then
			surface.SetFont("ass")
			local txt
			local col
			if target:IsPlayer() then
				txt = target:Name().." ("..math.max(0, target:Health())..")"
				col = team.GetColor(target:Team()) or COLOR_TEXTYELLOW
			else
				txt = "#"..target:GetClass()
				col = COLOR_TEXTYELLOW
			end
			local texw, texh = surface.GetTextSize(txt)
			draw_WordBox(w * 0.5, h - texh - 90, txt, "ass", col)
		end
	end

	local txt
	local col = COLOR_TEXTYELLOW
	local timeleft = math.max(0, GetGlobalFloat("endroundtime", 0) - CurTime())
	local lastchance
	if self:GetRoundEnded() then
		txt = "ROUND OVER"
	elseif self:GetIsCTF() then
		if timeleft <= 0 then
			for _, e in pairs(ents.FindByClass("prop_flag")) do
				if e:GetState() ~= FLAGSTATE_HOME then
					lastchance = true
					break
				end
			end
		end
	elseif self:GetNumBombTargets() > 0 then
		local bomb = ents.FindByClass("planted_bomb")[1]
		if bomb and bomb:IsValid() then
			local bombtimeleft = math.max(0, bomb:GetBombTime() - CurTime())
			if bombtimeleft == 0 and bomb:GetUseStart() ~= 0 then
				lastchance = true
			elseif bombtimeleft <= 10 then
				txt = "BOMB DETONATION: "..util.ToMinutesSecondsMilliseconds(bombtimeleft)
				col = RealTime() * 5 % 1 < 0.5 and COLOR_RED or COLOR_TEXTYELLOW
			else
				txt = "BOMB DETONATION: "..util.ToMinutesSeconds(bombtimeleft)
			end
		end
		--[[local holders = self:GetCaptureHolders()
		if holders == TEAM_T then
			local timeleft2 = math.max(0, self:GetCaptureEndTime() - CurTime())
			if timeleft2 <= 10 then
				txt = "BOMB DETONATION: "..util.ToMinutesSecondsMilliseconds(timeleft2)
				col = CurTime() * 5 % 1 < 0.5 and COLOR_RED or COLOR_TEXTYELLOW

				self:TickTock("weapons/c4/c4_click.wav", 200 - timeleft2 * 10)
			else
				txt = "BOMB DETONATION: "..util.ToMinutesSeconds(timeleft2)
				col = COLOR_RED
			end
		elseif holders == TEAM_CT then
			local timeleft2 = math.max(0, self:GetCaptureEndTime() - CurTime())
			if timeleft2 <= 10 then
				txt = "BOMB DEFUSAL: "..util.ToMinutesSecondsMilliseconds(timeleft2)
				col = CurTime() * 5 % 1 < 0.5 and COLOR_LIGHTBLUE or COLOR_TEXTYELLOW

				self:TickTock("buttons/blip1.wav", 200 - timeleft2 * 10)
			else
				txt = "BOMB DEFUSAL: "..util.ToMinutesSeconds(timeleft2)
				col = COLOR_LIGHTBLUE
			end
		else
			local holdingteam
			for _, ent in pairs(ents.FindByClass("point_capturezone")) do
				if ent:ShouldBeLastChance() then
					lastchance = true
					break
				end
				if holdingteam then
					if ent:GetTeam() > 0 and ent:GetTeam() ~= holdingteam then
						lastchance = true
						break
					end
				elseif ent:GetTeam() > 0 then
					holdingteam = ent:GetTeam()
				end
			end
		end]]
	elseif self:GetNumHostages() > 0 then
		if timeleft <= 0 then
			for _, e in pairs(ents.FindByClass("npc_hostage")) do
				if e:ShouldBeLastChance() then
					lastchance = true
					break
				end
			end
		end
	end

	if not txt and timeleft <= 10 then
		if lastchance then
			txt = "LAST CHANCE"
		else
			txt = util.ToMinutesSecondsMilliseconds(timeleft)
			col = CurTime() * 5 % 1 < 0.5 and COLOR_RED or COLOR_TEXTYELLOW
		end
	end

	if not txt then txt = util.ToMinutesSeconds(timeleft) end

	draw_WordBox(w * 0.5, h - 32 * screenscale, txt, "ass", col)

	self:DrawHUD(screenscale)
end

local matBlurScreen = Material("pp/blurscreen")
local matBlurEdges = Material("bluredges")
function GM:DrawHUDDistortion()
	matBlurEdges:SetFloat("$refractamount", math.sin(CurTime() * 3))
	surface.SetDrawColor(255, 255, 255, 1)
	surface.SetMaterial(matBlurEdges)
	surface.DrawTexturedRect(0, 0, w, h)
end

local healthpower = 0
local ammopower = 0
local healthtime = 0
GM.HUDFadeIn = 0
GM.HUDFadeInAmmo = 0
function GM:UpdateHUDComponents()
	if MySelf:Alive() then
		healthpower = math.Approach(healthpower, 1, FrameTime() * 2)
	else
		if healthpower > 0 then
			healthpower = math.Approach(healthpower, 0, FrameTime() * 4)
		end
	end

	local wep = MySelf:GetActiveWeapon()
	if wep:IsValid() and wep.Primary.Ammo ~= "none" then
		ammopower = math.Approach(ammopower, 1, FrameTime() * 2)
	elseif ammopower > 0 then
		ammopower = math.Approach(ammopower, 0, FrameTime() * 4)
	end

	self.HUDFadeIn = CosineInterpolation(0, 1, healthpower)
	self.HUDFadeInAmmo = CosineInterpolation(0, 1, ammopower)

	healthtime = (healthtime + FrameTime() * math.max(0.1, (1 - (math.max(0, MySelf:Health()) / 100)) * 10)) % 0xFF
	matBlurScreen:SetFloat("$blur", 25)
	matBlurEdges:SetFloat("$refractamount", 0)
	render.UpdateScreenEffectTexture()
end

function GM:DrawFancyRect(x, y, wid, hei, alpha)
	alpha = alpha or 90
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(matBlurScreen)
	surface.DrawTexturedRect(x, y, wid, hei)
	surface.SetMaterial(matBlurEdges)
	surface.DrawTexturedRect(x, y, wid, hei)
	surface.SetDrawColor(0, 0, 0, math.min(255, alpha * 2))
	surface.DrawOutlinedRect(x, y, wid, hei)
end

local colCritical = Color(255, 20, 0, 255)
function GM:DrawHealth(screenscale)
	if self.HUDFadeIn == 0 then return end

	local wid, hei = 192 * screenscale, 64 * screenscale
	local x, y = ScrW() * 0.25 - wid * 0.5, ScrH() - (hei + 16 * screenscale) * self.HUDFadeIn

	self:DrawFancyRect(x, y, wid, hei)

	local health = math.max(0, MySelf:Health())
	local col
	if health < 25 then
		col = colCritical
		col.a = 255 - math.abs(math.sin(CurTime() * 3)) * 160
	elseif health < 50 then
		col = COLOR_RED
	else
		col = COLOR_TEXTYELLOW
	end
	draw.SimpleText("b", "ass_icons", x + 8 * screenscale, y + 8 * screenscale, col)
	draw.SimpleText(string.format("%.3d", health), "ass_biggest_shadow", x + wid * 0.5, y + hei * 0.5 - 32 * screenscale, col, TEXT_ALIGN_CENTER)
end

function GM:DrawHealth3D(screenscale)
	if self.HUDFadeIn == 0 then return end

	local pos, ang = self:Get3D2DScreenPos(-1, -0.75 + (1 - self.HUDFadeIn))
	ang:RotateAroundAxis(ang:Right(), -30)

	cam.Start3D2D(pos, ang, 0.05)
	cam.IgnoreZ(true)

	local wid, hei = 192 * screenscale, 64 * screenscale
	local x, y = 0, 0

	self:DrawFancyRect(x, y, wid, hei)

	local health = math.max(0, MySelf:Health())
	local col
	if health < 25 then
		col = colCritical
		col.a = 255 - math.abs(math.sin(CurTime() * 3)) * 160
	elseif health < 50 then
		col = COLOR_RED
	else
		col = COLOR_TEXTYELLOW
	end
	draw.SimpleText("b", "ass_icons", x + 8 * screenscale, y + 8 * screenscale, col)
	draw.SimpleText(string.format("%.3d", health), "ass_biggest_shadow", x + wid * 0.5, y + hei * 0.5 - 32 * screenscale, col, TEXT_ALIGN_CENTER)

	cam.IgnoreZ(false)
	cam.End3D2D()
end

function GM:DrawAmmo(screenscale)
	if self.HUDFadeInAmmo == 0 then return end

	local wid, hei = 192 * screenscale, 64 * screenscale
	local x, y = ScrW() * 0.75 - wid * 0.5, ScrH() - (hei + 16 * screenscale) * self.HUDFadeInAmmo

	self:DrawFancyRect(x, y, wid, hei)

	local wep = MySelf:GetActiveWeapon()
	if wep:IsValid() and wep.Primary and wep.Primary.Ammo ~= "none" then
		local clip = wep:Clip1()
		local clipsize = wep.Primary.ClipSize
		local col
		if clip < clipsize * 0.25 then
			col = colCritical
			col.a = 255 - math.abs(math.sin(CurTime() * 3)) * 160
		elseif clip < clipsize * 0.5 then
			col = COLOR_RED
		else
			col = COLOR_TEXTYELLOW
		end
		draw.SimpleText(string.format("%.2d", wep:Clip1()), "ass_bigger_shadow", x + wid * 0.45, y + hei * 0.25 - 24 * screenscale, col, TEXT_ALIGN_RIGHT)
		draw.SimpleText(wep.Primary.DefaultClip < 9999 and string.format("%.2d", wep.Primary.DefaultClip) or "INF", "ass_shadow", x + wid * 0.55, y + hei * 0.75 - 16 * screenscale, COLOR_TEXTYELLOW, TEXT_ALIGN_LEFT)
	end
end

function GM:DrawAmmo3D(screenscale)
	if self.HUDFadeInAmmo == 0 then return end

	local pos, ang = self:Get3D2DScreenPos(1, -0.75 + (1 - self.HUDFadeInAmmo))
	ang:RotateAroundAxis(ang:Right(), 30)

	cam.Start3D2D(pos, ang, 0.05)
	cam.IgnoreZ(true)

	local wid, hei = 192 * screenscale, 64 * screenscale
	local x, y = 0, 0

	self:DrawFancyRect(x, y, wid, hei)

	local wep = MySelf:GetActiveWeapon()
	if wep:IsValid() and wep.Primary and wep.Primary.Ammo ~= "none" then
		local clip = wep:Clip1()
		local clipsize = wep.Primary.ClipSize
		local col
		if clip < clipsize * 0.25 then
			col = colCritical
			col.a = 255 - math.abs(math.sin(CurTime() * 3)) * 160
		elseif clip < clipsize * 0.5 then
			col = COLOR_RED
		else
			col = COLOR_TEXTYELLOW
		end
		draw.SimpleText(string.format("%.2d", wep:Clip1()), "ass_bigger_shadow", x + wid * 0.45, y + hei * 0.25 - 24 * screenscale, col, TEXT_ALIGN_RIGHT)
		draw.SimpleText(wep.Primary.DefaultClip < 9999 and string.format("%.2d", wep.Primary.DefaultClip) or "INF", "ass_shadow", x + wid * 0.55, y + hei * 0.75 - 16 * screenscale, COLOR_TEXTYELLOW, TEXT_ALIGN_LEFT)
	end

	cam.IgnoreZ(false)
	cam.End3D2D()
end

function GM:DrawEnergy(screenscale)
	if self.HUDFadeIn == 0 then return end

	local wid, hei = 256 * screenscale, 64 * screenscale
	local x, y = ScrW() * 0.5 - wid * 0.5, ScrH() - (hei + 80 * screenscale) * self.HUDFadeIn

	if not MySelf:GetSkillTable().DrawEnergy then
		hei = hei - 16 * screenscale
		y = y + 16 * screenscale
		self:DrawFancyRect(x, y, wid, hei)

		draw.SimpleText("SKILL", "ass_smaller_shadow", x + 8 * screenscale, y + 8 * screenscale, COLOR_TEXTYELLOW, TEXT_ALIGN_LEFT)
		draw.SimpleText(MySelf:GetSkillTable().Name, "ass_smaller_shadow", x + 8 * screenscale, y + 26 * screenscale, COLOR_TEXTYELLOW, TEXT_ALIGN_LEFT)

		return
	end

	self:DrawFancyRect(x, y, wid, hei)

	local energy = MySelf:GetEnergy()
	local energypercent = energy / MySelf:GetMaxEnergy()
	local col
	if energy < 25 then
		col = colCritical
		col.a = 255 - math.abs(math.sin(CurTime() * 3)) * 160
	elseif energy < 50 then
		col = COLOR_RED
	else
		col = COLOR_TEXTYELLOW
	end

	local bary = y + hei - 24

	draw.SimpleText("SKILL", "ass_smaller_shadow", x + 8 * screenscale, bary - 34 * screenscale, COLOR_TEXTYELLOW, TEXT_ALIGN_LEFT)
	draw.SimpleText(MySelf:GetSkillTable().Name, "ass_smaller_shadow", x + 8 * screenscale, bary - 18 * screenscale, COLOR_TEXTYELLOW, TEXT_ALIGN_LEFT)
	draw.SimpleText(string.format("%.3d", energy), "ass_shadow", x + wid - 8 * screenscale, bary - 34 * screenscale, col, TEXT_ALIGN_RIGHT)

	surface.SetDrawColor(5, 5, 5, 90)
	surface.DrawRect(x + 8 * screenscale, bary, wid - 16 * screenscale, 16 * screenscale)
	surface.SetDrawColor(col)
	surface.DrawRect(x + 10 * screenscale, bary + 2 * screenscale, (wid - 20 * screenscale) * energypercent, 12 * screenscale)
	surface.SetDrawColor(COLOR_TEXTYELLOW)
	surface.DrawOutlinedRect(x + 8 * screenscale, bary, wid - 16 * screenscale, 16 * screenscale)
end

function GM:DrawHUD(screenscale)
	self:UpdateHUDComponents()

	self:DrawHealth(screenscale)
	self:DrawAmmo(screenscale)
	self:DrawEnergy(screenscale)

	self:DrawHurtOtherTick(screenscale)
end

GM.LastHurtOtherTick = 0
local texFlash = surface.GetTextureID("awesomestrike/simplecircle")
function GM:DrawHurtOtherTick(screenscale)
	if CurTime() > self.LastHurtOtherTick + 0.5 then return end

	local size = screenscale * 48

	surface.SetTexture(texFlash)
	surface.SetDrawColor(255, 255, 255, (0.5 - (CurTime() - self.LastHurtOtherTick)) * 255)
	surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, size, size, CurTime() * 360)
end

function GM:ShutDown()
end

function GM:RenderScreenspaceEffects()
end

GM.HurtEffect = 0
function GM:_RenderScreenspaceEffects()
	MySelf:CallStateFunction("RenderScreenspaceEffects")

	if render.GetDXLevel() < 80 then return end

	if self.HurtEffect > 0 then
		DrawSharpen(1, math.min(6, self.HurtEffect * 3))
	end
end

function GM:PostProcessPermitted(pp)
	return false
end

function GM:GetTeamColor(ent)
	local teamid = TEAM_UNASSIGNED
	if ent.Team then teamid = ent:Team() end
	return team.GetColor(teamid) or color_white
end

function GM:_AdjustMouseSensitivity()
	return MySelf:CallStateFunction("AdjustMouseSensitivity") or self.BaseClass.AdjustMouseSensitivity(self)
end

usermessage.Hook("EndG", function(um)
	local winner = um:ReadShort()
	END_GAME = true
	NEXT_MAP = CurTime() + GetConVarNumber("as_votetime")

	RunConsoleCommand("+showscores")
end)

GM.FOV = 90

local roll = 0
local lerpfov
function GM:CalcView(pl, origin, angles, fov, znear, zfar)
	if pl:GetObserverMode() == OBS_MODE_IN_EYE then
		local target = pl:GetObserverTarget()
		if target and target:IsValid() and target:IsPlayer() then
			pl = target
		end
	elseif pl:GetObserverMode() == OBS_MODE_CHASE and self.LockedChaseCam then
		local target = pl:GetObserverTarget()
		if target and target:IsValid() and target:IsPlayer() then
			angles = target:EyeAngles()
			origin = target:GetThirdPersonCameraPos(target:EyePos(), angles)
		end
	end

	local targetroll = 0
	local targetfov = fov
	if pl:Alive() then
		local state = pl:GetState()
		if state == STATE_SLIDE then
			targetroll = math.AngleDifference(angles.yaw, pl:GetStateAngles().yaw) * 0.5
		elseif state == STATE_WALLRUN then
			local hitpos, hitnormal = pl:GetWallRunSurface()
			if hitpos then
				targetroll = math.AngleDifference(angles.yaw, hitnormal:Angle().yaw) * 0.25
			end
		end

		if state == STATE_AWESOMERIFLEEND or state == STATE_AWESOMELAUNCHEREND then
			local tr = util.TraceLine({start = pl:GetStateVector(), endpos = pl:GetStateVector() - angles:Forward() * 128, mask = MASK_SOLID_BRUSHONLY})
			origin = tr.HitPos + tr.HitNormal
		elseif state == STATE_AWESOMELAUNCHERGUIDE then
			local bomb = pl:GetStateEntity()
			if bomb:IsValid() then
				local start = bomb:GetPos()
				local tr = util.TraceLine({start = start, endpos = start - angles:Forward() * 128, mask = MASK_SOLID_BRUSHONLY})
				origin = tr.HitPos + tr.HitNormal
			end
		elseif state == STATE_AWESOMERIFLEGUIDE then
			local bullet = pl:GetStateEntity()
			if bullet:IsValid() then
				origin = bullet:GetPos() + angles:Forward() * 4
			end
		elseif state == STATE_KNOCKEDDOWN then
			local rpos, rang = self:GetRagdollEyes(pl)
			if rpos then
				origin = pl:GetThirdPersonCameraPos(rpos, angles)
			else
				origin = pl:GetThirdPersonCameraPos(origin, angles)
			end
		elseif pl:ShouldDrawLocalPlayer() then
			origin = pl:GetThirdPersonCameraPos(origin, angles)
		end

		if pl:IsPlayingTaunt() then
			self:CalcViewTaunt(pl, origin, angles, fov, zclose, zfar)
		end
	end

	if pl:GetObserverMode() == OBS_MODE_NONE then
		local vel = pl:GetVelocity()
		targetroll = targetroll + vel:GetNormalized():Dot(angles:Right()) * math.min(30, vel:Length() / 100)
	end

	local ft = FrameTime()
	local vel = pl:GetVelocity()
	local speed = vel:Length()
	targetfov = targetfov + fov * math.Clamp(math.abs(angles:Forward():Dot(vel:GetNormalized())) * ((speed - 125) / 300), 0, 2) * 0.035
	lerpfov = math.Approach(lerpfov or targetfov, targetfov, ft * 60)

	roll = math.Approach(roll, targetroll, math.max(0.25, math.sqrt(math.abs(roll))) * 30 * ft)
	angles.roll = angles.roll + roll

	self.FOV = lerpfov

	return self.BaseClass.CalcView(self, pl, origin, angles, lerpfov, znear, zfar)
end

function GM:CalcViewTaunt(pl, origin, angles, fov, zclose, zfar)
	local tr = util.TraceHull({start = origin, endpos = origin - angles:Forward() * 72, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), mask = MASK_OPAQUE, filter = pl})
	origin:Set(tr.HitPos + tr.HitNormal * 2)
end

function GM:PreDrawViewModel(viewmodel, pl, wep)
	if wep then
		return pl:CallStateFunction("PreDrawViewModel", viewmodel) or pl:CallSkillFunction("PreDrawViewModel", viewmodel)
	end
end

function GM:PostDrawViewModel(viewmodel, pl, wep)
	if wep then
		return pl:CallStateFunction("PostDrawViewModel", viewmodel) or pl:CallSkillFunction("PostDrawViewModel", viewmodel)
	end
end

local dontdraw = {}
dontdraw["CHudSecondaryAmmo"] = true
dontdraw["CHudAmmo"] = true
dontdraw["CHudHealth"] = true
dontdraw["CHudBattery"] = true
function GM:_HUDShouldDraw(name)
	if name == "CHudDamageIndicator" or name == "CHudCrosshair" then return MySelf:Alive() end

	return dontdraw[name] == nil
end

local function DoClick(self)
	surface.PlaySound("buttons/button15.wav")
	self:DoClick2()
end

local function DoRightClick(self)
	surface.PlaySound("buttons/button15.wav")
	self:DoRightClick2()
end

function CSButton(parent, text, doclick, dorightclick, thinkhook)
	local button = vgui.Create("DButton", parent)
	button:SetText(text)
	button:SetFont("ass14")
	--button:SetTextColor(COLOR_TEXTYELLOW)
	button:SetSize(300, 48)
	if doclick then
		button.DoClick = DoClick
		button.DoClick2 = doclick
	end
	if dorightclick then
		button.DoRightClick = DoRightClick
		button.DoRightClick2 = dorightclick
	end
	if thinkhook then
		button.Think = thinkhook
	end

	return button
end

local dependancies = {}
hook.Add("PostRenderVGUI", "StlishBackgroundPostRenderVGUI", function()
	if #dependancies == 0 then return end

	for _, panel in pairs(dependancies) do
		if panel and panel:Valid() and panel:IsVisible() then
			return
		end
	end

	dependancies = {}
end)

local starttime
function DrawStylishBackground(panel)
	if not table.HasValue(dependancies, panel) then
		table.insert(dependancies, panel)
		if #dependancies == 1 then
			starttime = RealTime()
		end
	end
end

local boxsize = 64
local space = boxsize * 4
local halfboxsize = boxsize / 2
local texGear = surface.GetTextureID("awesomestrike/gear2")
local texGear2 = surface.GetTextureID("awesomestrike/gear1")
local texGrad = surface.GetTextureID("gui/gradient")
function PaintStylishBackground()
	local rt = RealTime()
	local fadein = starttime and math.Clamp(rt - starttime, 0, 1) or 1
	local basealpha = 180 * fadein

	local rotation = rt * fadein * 30

	local wid, hei = ScrW(), ScrH()
	local mousex, mousey = gui.MousePos()

	surface.SetDrawColor(0, 0, 0, basealpha)
	surface.DrawRect(0, 0, wid, hei)

	local alt
	surface.SetTexture(texGear)
	for x = rt * 100 % space - boxsize, wid, space do
		for y = rt * 30 % space - boxsize - space * 0.5, hei, space do
			alt = not alt
			local centerx = x + halfboxsize
			local centery = y + halfboxsize
			local brightness = 1 - math.Clamp((math.sqrt(math.abs(centerx - mousex) ^ 2 + math.abs(centery - mousey) ^ 2) - halfboxsize) / space, 0, 1)
			surface.SetDrawColor(255 * brightness, 177 * brightness, 0, basealpha)
			surface.DrawTexturedRectRotated(centerx, centery, boxsize, boxsize, alt and rotation or -rotation)
		end
	end

	local size = (0.5 + fadein * 0.5) * BetterScreenScale() * 256
	local offset = size * (0.15 - (1 - fadein))

	surface.SetTexture(texGrad)
	surface.SetDrawColor(0, 0, 0, 255 * fadein)
	surface.DrawTexturedRectRotated(offset, hei * 0.5, size, hei, 0)
	surface.DrawTexturedRectRotated(wid - offset, hei * 0.5, size, hei, 180)
	for i=1, 2 do
		surface.DrawTexturedRectRotated(wid * 0.5, hei - offset, size, wid, 90)
		surface.DrawTexturedRectRotated(wid * 0.5, offset, size, wid, 270)
	end

	local csize = size * fadein * 1.25
	surface.SetTexture(texCircle)
	surface.SetDrawColor(0, 0, 0, 90 * fadein)
	surface.DrawTexturedRectRotated(offset, offset, csize, csize, 0)
	surface.DrawTexturedRectRotated(offset, hei - offset, csize, csize, 0)
	surface.DrawTexturedRectRotated(wid - offset, hei - offset, csize, csize, 0)
	surface.DrawTexturedRectRotated(wid - offset, offset, csize, csize, 0)

	rotation = rotation * 2
	surface.SetTexture(texGear2)
	surface.SetDrawColor(255, 177, 0, 255 * fadein)
	surface.DrawTexturedRectRotated(offset, offset, size, size, rotation)
	surface.DrawTexturedRectRotated(offset, hei - offset, size, size, rotation)
	surface.DrawTexturedRectRotated(wid - offset, hei - offset, size, size, -rotation)
	surface.DrawTexturedRectRotated(wid - offset, offset, size, size, -rotation)
end

function GM:HUDPaintBackground()
	if not MySelf:IsValid() then return end

	if #dependancies > 0 then
		PaintStylishBackground()
	end

	local ct = CurTime()

	if self:GetNumBombTargets() > 0 then
		for _, ent in pairs(ents.FindByClass("planted_bomb")) do
			self:DrawBeacon(ent:GetPos(), 255, 10, 10)
		end

		--[[local myteam = MySelf:Team()
		local isspec = myteam == TEAM_SPECTATOR
		for i, ent in ipairs(ents.FindByClass("point_capturezone")) do
			local entteam = ent:GetTeam()
			if entteam == 0 then
				self:DrawBeacon(ent:GetPos(), 255, 177, 0)
			elseif isspec then
				if entteam == TEAM_T then
					self:DrawBeacon(ent:GetPos(), 255, 10, 10)
				elseif entteam == TEAM_CT then
					self:DrawBeacon(ent:GetPos(), 10, 80, 255)
				end
			elseif myteam == ent:GetTeam() then
				self:DrawBeacon(ent:GetPos(), 30, 255, 30)
			else
				self:DrawBeacon(ent:GetPos(), 255, 10, 10)
			end
			local sc = ent:GetPos():ToScreen()
			draw.SimpleText(i, "ass16_shadow", sc.x, sc.y, COLOR_TEXTYELLOW, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end]]
	elseif self:GetNumHostages() > 0 then
		for _, ent in pairs(ents.FindByClass("npc_hostage")) do
			self:DrawBeacon(ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z * 0.5), 10, 80, 255)
		end
	elseif self:GetIsCTF() then
		local myteam = MySelf:Team()
		local isspec = myteam == TEAM_SPECTATOR
		for _, ent in pairs(ents.FindByClass("prop_flag")) do
			local pos = ent:GetPos()

			if isspec then
				local col = ent:GetColor()
				self:DrawBeacon(pos, col.r, col.g, col.b)
			elseif ent:GetTeam() == myteam then
				self:DrawBeacon(pos, 30, 255, 30)
			else
				self:DrawBeacon(pos, 255, 10, 10)
			end

			if ent:GetAutoReturn() ~= 0 then
				local toscreen = pos:ToScreen()
				draw.SimpleText(math.ceil(math.max(0, ent:GetAutoReturn() - CurTime())), "ass16_shadow", toscreen.x, toscreen.y, COLOR_TEXTYELLOW, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	elseif MySelf:Team() == TEAM_SPECTATOR or MySelf:GetDiedThisRound() then
		local d = CurTime() * 2 % 1
		local size = d * 32
		local hsize = size / 2
		surface.SetTexture(texCircle)
		local myteam = MySelf:Team()
		if myteam == TEAM_SPECTATOR then
			surface.SetDrawColor(255, 10, 10, (1 - d) * 200)
			for _, ent in pairs(team.GetPlayers(TEAM_T)) do
				if not ent:GetDiedThisRound() and ent:Alive() then
					local vis = ent:CallStateFunction("GetVisibility")
					if not vis or vis == 1 then
						local pos = (ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z * 0.5)):ToScreen()
						surface.DrawTexturedRect(pos.x - hsize, pos.y - hsize, size, size)
					end
				end
			end
			surface.SetDrawColor(30, 30, 255, (1 - d) * 200)
			for _, ent in pairs(team.GetPlayers(TEAM_T)) do
				if not ent:GetDiedThisRound() and ent:Alive() then
					local vis = ent:CallStateFunction("GetVisibility")
					if not vis or vis == 1 then
						local pos = (ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z * 0.5)):ToScreen()
						surface.DrawTexturedRect(pos.x - hsize, pos.y - hsize, size, size)
					end
				end
			end
		else
			surface.SetDrawColor(30, 255, 30, (1 - d) * 200)
			for _, ent in pairs(team.GetPlayers(myteam)) do
				if not ent:GetDiedThisRound() and ent:Alive() then
					local pos = (ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z * 0.5)):ToScreen()
					surface.DrawTexturedRect(pos.x - hsize, pos.y - hsize, size, size)
				end
			end
			surface.SetDrawColor(255, 10, 10, (1 - d) * 200)
			for _, ent in pairs(team.GetPlayers(myteam == TEAM_T and TEAM_CT or TEAM_T)) do
				if not ent:GetDiedThisRound() and ent:Alive() then
					local vis = ent:CallStateFunction("GetVisibility")
					if not vis or vis == 1 then
						local pos = (ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z * 0.5)):ToScreen()
						surface.DrawTexturedRect(pos.x - hsize, pos.y - hsize, size, size)
					end
				end
			end
		end
	end

	if self.DeathIconEnd and ct < self.DeathIconEnd then
		local CurTime = CurTime()

		local RealSeed1 = math.sin(CurTime * 18) * 100 + 155
		local RealSeed2 = math.cos(CurTime * 24) * 100 + 155

		local alpha = math.Clamp(self.DeathIconEnd - ct, 0, 1) * 220
		surface.SetDrawColor(RealSeed1, RealSeed2, math.sin(CurTime * -20) * 100 + 155, alpha)
		surface.SetFont("ass_shadow")
		local texw, texh = surface.GetTextSize("W")
		surface.DrawRect(0, h * 0.7 - 12, w, 10)
		surface.DrawRect(0, h * 0.7 + texh + 2, w, 10)
		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawRect(0, h * 0.7 - 2, w, texh + 4)
		draw.SimpleText("You were killed by "..self.DeathIconName.."!", "ass_shadow", w * 0.5, h * 0.7, Color(RealSeed2, RealSeed1, math.cos(CurTime * -25) * 100 + 155, alpha), TEXT_ALIGN_CENTER)
	end

	self:DrawCombo()

	if self.StartRoundNotifyEnd and ct < self.StartRoundNotifyEnd then
		local fadein = math.Clamp(math.min(self.StartRoundNotifyEnd - ct, ct - self.StartRoundNotifyStart) ^ 2, 0, 1)
		local wid = 300 * BetterScreenScale()
		draw_SuperFancyGear(fadein * wid - wid * 1.15, h - fadein * wid * 0.85, wid, GlowColor(coltemp, COLOR_TEXTYELLOW), "ROUND "..self:GetRound(), "ass_bigger_shadow")
	end
end

--[[function GM:CalcView()
end
GM.Think = GM.CalcView
GM.CreateMove = GM.CalcView
GM.Move = GM.CalcView
GM.AdjustMouseSensitivity = GM.CalcView
GM.ShouldDrawLocalPlayer =  GM.CalcView]]

-- Temporary fix
function render.DrawQuadEasy(pos, dir, xsize, ysize, color, rotation)
	xsize = xsize / 2
	ysize = ysize / 2

	local ang = dir:Angle()

	if rotation then
		ang:RotateAroundAxis(ang:Forward(), rotation)
	end

	local upoffset = ang:Up() * ysize
	local rightoffset = ang:Right() * xsize

	render.DrawQuad(pos - upoffset - rightoffset, pos - upoffset + rightoffset, pos + upoffset + rightoffset, pos + upoffset - rightoffset, color)
end
