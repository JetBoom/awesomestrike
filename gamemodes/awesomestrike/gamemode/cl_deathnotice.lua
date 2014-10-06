usermessage.Hook("AwesomeStrikePlayerKilled", function(um)
	local victim = um:ReadEntity()
	local attacker = um:ReadEntity()
	local maintype = um:ReadShort()
	local subtypes = um:ReadLong()

	if attacker ~= victim then
		if victim == MySelf then
			gamemode.Call("Died", attacker)
		elseif attacker == MySelf then
			GAMEMODE:AddSubTypesToComboArea(GAMEMODE:BitsToKillAction2(subtypes))
		end
	end

	if victim:IsValid() then
		local attackerisplayer = attacker:IsValid() and attacker:IsPlayer()
		gamemode.Call("AddDeathNotice",
		attacker == victim and "themself" or victim:Name(), attacker == victim and 0 or victim:Team(),
		attackerisplayer and attacker:Name() or attacker:IsValid() and attacker:GetClass() or "The World", attackerisplayer and attacker:Team() or 0,
		string.upper(GAMEMODE:KillMessageMainTypeToString(maintype)), GAMEMODE:BitsToKillAction2(subtypes),
		attacker == MySelf or victim == MySelf)

		if attacker == MySelf and victim ~= MySelf then
			surface.PlaySound("buttons/lightswitch2.wav")
		end
	end
end)

usermessage.Hook("AwesomeStrikePlayerRevived", function(um)
	local victim = um:ReadEntity()
	local attacker = um:ReadEntity()

	if victim:IsValid() then
		gamemode.Call("AddDeathNotice",
		victim:Name(), victim:Team(),
		attacker:Name(), attacker:Team(),
		"REVIVED", {0},
		attacker == MySelf or victim == MySelf)

		if attacker == MySelf and victim ~= MySelf then
			surface.PlaySound("buttons/lightswitch2.wav")
		end
	end
end)

local Deaths = {}

function GM:AddDeathNotice(victimstring, victimteam, attackerstring, attackerteam, maintype, subtypes, highlighted)
	local death = {}
	death.victim = " "..victimstring.." "
	death.attacker = attackerstring.." "
	death.starttime = CurTime()
	death.endtime = death.starttime + 8
	death.maintype = " "..maintype.." "
	death.highlighted = highlighted
	death.subtypes = subtypes
	death.subtypewidth = 0
	if subtypes then
		surface.SetFont("ass_smaller")
		for _, subtype in pairs(subtypes) do
			local str = self.KillMessageSubTypeStrings[subtype]
			if str then
				str = "("..str.."!)"
				local texw, texh = surface.GetTextSize(str)
				death.subtypewidth = math.max(death.subtypewidth, texw)
			end
		end
	end
	death.victimcolor = table.Copy(team.GetColor(victimteam) or color_white)
	death.attackercolor = table.Copy(team.GetColor(attackerteam) or color_white)
	table.insert(Deaths, death)
end

local function DrawText(text, font, x, y, col)
	surface.SetFont(font)
	local texw, texh = surface.GetTextSize(text)
	draw.SimpleText(text, font, x, y, col, TEXT_ALIGN_RIGHT)
	x = x - texw
	return x
end
local colGeneric = Color(255, 255, 255, 255)
local texGrad = surface.GetTextureID("gui/gradient")
local function DrawDeath(x, y, death)
	local fadein = math.Clamp(math.min(death.endtime - CurTime(), CurTime() - death.starttime) * 2, 0, 1)
	local alpha = 200 * fadein
	death.victimcolor.a = alpha
	death.attackercolor.a = alpha
	colGeneric.a = alpha

	x = x + (1 - fadein) * 512

	surface.SetTexture(texGrad)
	if death.highlighted then
		surface.SetDrawColor(120, 120, 120, alpha)
	else
		surface.SetDrawColor(5, 5, 5, alpha * 0.5)
	end
	surface.DrawTexturedRectRotated((x - 512) + 256, y + 14, 512, 28, 90 + fadein * 90)

	y = y + 2
	if death.subtypes and #death.subtypes > 0 then
		local str = GAMEMODE.KillMessageSubTypeStrings[ death.subtypes[math.min(#death.subtypes, math.floor(CurTime() % #death.subtypes + 1))] ]
		if str then
			str = "("..str.."!)"
			DrawText(str, "ass_smaller", x, y + 4, colGeneric)
		end
		x = x - death.subtypewidth
	end
	x = DrawText(death.victim, "ass_small", x, y, death.victimcolor)
	x = DrawText(death.maintype, "ass_smaller", x, y + 4, colGeneric)
	DrawText(death.attacker, "ass_small", x, y, death.attackercolor)

	return y + 26
end

function GM:DrawDeathNotice(x, y)
	if #Deaths == 0 then return end

	local done = true
	for k, death in ipairs(Deaths) do
		if CurTime() < death.endtime then
			done = false
			y = DrawDeath(x, y, death)
		end
	end

	if done then
		Deaths = {}
	end
end
