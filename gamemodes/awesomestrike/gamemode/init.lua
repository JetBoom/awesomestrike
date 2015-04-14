AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("sh_teams.lua")

AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("sh_states.lua")
AddCSLuaFile("sh_skills.lua")
AddCSLuaFile("sh_voicesets.lua")
AddCSLuaFile("sh_bullets.lua")
AddCSLuaFile("sh_statushook.lua")

AddCSLuaFile("obj_entity_extend_cl.lua")
AddCSLuaFile("obj_player_extend_cl.lua")
AddCSLuaFile("obj_entity_extend.lua")
AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("obj_weapon_extend.lua")

AddCSLuaFile("cl_animeditor.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_notice.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("cl_dermaskin.lua")
AddCSLuaFile("cl_radio.lua")

AddCSLuaFile("vgui/dmodelpanel2.lua")
AddCSLuaFile("vgui/dweaponicon.lua")
AddCSLuaFile("vgui/dweaponstats.lua")
AddCSLuaFile("vgui/dskillicon.lua")
AddCSLuaFile("vgui/dskillstats.lua")
AddCSLuaFile("vgui/dsplash.lua")
AddCSLuaFile("vgui/pbuymenu.lua")
AddCSLuaFile("vgui/pteams.lua")
AddCSLuaFile("vgui/phelp.lua")
AddCSLuaFile("vgui/pcharacter.lua")

AddCSLuaFile("cl_scoreboard.lua")

include("obj_entity_extend_sv.lua")
include("obj_player_extend_sv.lua")

include("sv_streaks.lua")

include("boneanimlib.lua")

include("shared.lua")

--[[

[b][size=5]Awesome Strike: Source[/size][/b]
[*][color=red]Added a free for all game type. There are no teams or reviving. First person to 10 kills wins a round. gg_ and dm_ maps use this game type.[/color]
[*][color=red]Players can now climb walls vertically. To do this, sprint directly (< 10 degrees) at a tall enough wall. You can only run up a certain height before falling back down. Your camera will be locked facing upwards. Speed mastery enhances the height that you can reach.[/color]
[*][color=red]Added random gameplay tips while dead.[/color]
[*][color=red]Hostages now drop dead if the terrorist team wins a hostage rescue map.[/color]
[*][color=red]Added a stylish splash screen. Gives you option to start playing, get help, options, open radio, etc. Replaces F1.[/color]
[*][color=red]Added a hit ding sound. Off by default, you can turn it on in options.[/color]
[*][color=red]Added a stylish screen splash for when a team wins.[/color]
[*][color=red]Objectives HUD made to look a bit better.[/color]
[*][color=red]Punching or otherwise bashing windows (no bullets) will throw tons of dangerous shrapnel in the bash direction. A kill action is available for it. Players who are knocked down can also trigger this by ramming through the window.[/color]
[*][color=red]Added new Kills column in the scoreboard to separate points from kills.[/color]
[*][color=red]Added the Sawarang to the primary weapons pool. This is essentially a boomerang made out of a saw blade. Throw it and it will return to you after about 3 seconds. Hitting a solid object like a wall will get it stuck and grinding in place before returning to you. Press right click to throw without it bothering to have it return.[/color]
[*][color=red]Bicycle props can now be ridden around and used to crash in to people / objects. You can still be damaged while on it. Getting hit with seizure grenades, knock back, or any other status altering effect will throw you off of it. This is just the first in what should be a list of environmental weapons. Things hit will be damaged and thrown back based on velocity of the bike minus velocity of the object being hit.[/color]
[*][color=red]Added the Construction active skill. Allows you to place a variety of destroyable objects. Each structure requires a certain amount of energy. Energy starts at 0 and regenerates slowly over time. Structures have about 200 health and are resistant to bullets. Construction takes about 5 seconds and you can visibly see how far along the construction is underway because it slowly changes from wire frame to solid object. Structures range in size from small crates to blast walls. There is a slot-based maximum amount of objects (walls take lots of slots, boxes take less). Props are team-colored, have a slight visual effect, and use a non-standard material.[/color]
[*][color=red]Added the Attack Orb, Defense Orb, and Speed Orb to the tertiary weapons pool.
[*][color=red]Added a menu for the radio. You can now pick a genre and a station as well as control the volume. You can also check off if you want the radio to be playing every map.[/color]
[*][color=red]Added an entirely new system: enhancement chips. Chips will occasionally drop when doing objectives and there's enough people in the server. These chips will give buffs and debuffs to specific weapons, skills, or the player and only one can be active on each weapon, skill, or player. Effects range from simple number changes to adding new effects. These are permanent so you now have a backpack which holds up to 25 of these. There are also unique and rare chips that are named instead of randomly generated. Finally, these are also stored in a central database so when AS:S is released then you can use them on any other server running AS:S. Deleting and trading will be done with HTTP directly between clients.[/color]

]]

if #file.Find(GM.FolderName.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") > 0 then
	include("maps/"..game.GetMap()..".lua")
end

gmod.BroadcastLua = gmod.BroadcastLua or function(lua)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(lua)
	end
end

function GM:AddNotice(message, lifetime, colorid, filter)
	umsg.Start("AddNotice", filter)
		umsg.String(message or "")
		umsg.Float(lifetime or 5)
		umsg.Short(colorid or 0)
	umsg.End()
end

function GM:Initialize()
	resource.AddFile("materials/noxctf/sprite_bloodspray1.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray2.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray3.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray4.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray5.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray6.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray7.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray8.vmt")
	resource.AddFile("materials/refract_ring.vmt")
	resource.AddFile("materials/bluredges.vmt")
	resource.AddFile("sound/nox/stunon.wav")
	resource.AddFile("sound/nox/stunoff.wav")

	resource.AddFile("resource/fonts/cstrike.ttf")
	resource.AddFile("resource/fonts/hidden.ttf")

	resource.AddFile("particles/vman_explosion.pcf")

	for _, filename in pairs(file.Find("models/peanut/*.*", "GAME")) do
		resource.AddFile("models/peanut/"..filename)
	end
	for _, filename in pairs(file.Find("materials/peanut/*.*", "GAME")) do
		resource.AddFile("materials/peanut/"..filename)
	end

	for _, filename in pairs(file.Find("materials/awesomestrike/*.vmt", "GAME")) do
		resource.AddFile("materials/awesomestrike/"..filename)
	end

	for _, filename in pairs(file.Find("sound/awesomestrike/*.wav", "GAME")) do
		resource.AddFile("sound/awesomestrike/"..filename)
	end
	for _, filename in pairs(file.Find("sound/awesomestrike/*.mp3", "GAME")) do
		resource.AddFile("sound/awesomestrike/"..filename)
	end

	util.AddNetworkString("as_weaponbindslots")

	self:AddParticles()
	self:RecycleOldWinStreaks()
end

function GM:ShouldScrambleTeams()
	if GetConVarNumber("as_scrambleteams") == 0 then return end

	local playing = team.NumPlayers(TEAM_T) + team.NumPlayers(TEAM_CT)
	if playing <= 4 then return false end
	local tscore = team.TotalPoints(TEAM_T)
	local ctscore = team.TotalPoints(TEAM_CT)
	if ctscore + tscore < playing then return false end

	local spread = math.max(tscore, 1) / math.max(ctscore, 1)
	return spread <= 0.5 or spread >= 2
end

local function balancingsort(a, b)
	if a:Frags() == b:Frags() then
		if a:Kills() == b:Kills() then
			return a:Deaths() < b:Deaths()
		end

		return a:Kills() > b:Kills()
	end

	return a:Frags() > b:Frags()
end
function GM:ScrambleTeams(nobalance)
	local tobebalanced = {}
	for _, pl in pairs(player.GetAll()) do
		if pl:Team() == TEAM_T or pl:Team() == TEAM_CT then table.insert(tobebalanced, pl) end
	end

	if #tobebalanced <= 2 then return end

	table.sort(tobebalanced, balancingsort)

	math.randomseed(os.time())

	local team1, team2
	if math.Rand(0, 1) < 0.5 then
		team1 = TEAM_CT
		team2 = TEAM_T
	else
		team1 = TEAM_T
		team2 = TEAM_CT
	end

	for i, pl in ipairs(tobebalanced) do
		pl:ChangeTeam(i % 2 == 0 and team1 or team2, true, true)
	end

	self:AddNotice("Teams have been scrambled!~snpc/advisor/advisor_blast1.wav", 7)

	if self:ShouldScrambleTeams() then
		self.BadJobAtScrambling = 2
	end
end

function GM:SetSpectatorTarget(pl, target)
	if IsValid(target) and not (target:IsPlayer() and not target:Alive()) then
		pl:SpectateEntity(target)
		pl:Spectate(pl.SpectateInEye and OBS_MODE_IN_EYE or OBS_MODE_CHASE)
	else
		pl:SpectateEntity(NULL)
		pl:Spectate(OBS_MODE_ROAMING)
	end
end

function GM:GetSpectatorTargets(pl, nonstrict)
	local potential = {}

	local players
	if pl:Team() == TEAM_SPECTATOR then
		players = team.GetPlayers(TEAM_T)
		players = table.Add(players, team.GetPlayers(TEAM_CT))
	else
		players = team.GetPlayers(pl:Team())
	end

	for _, ent in ipairs(players) do
		if nonstrict or ent:IsValidSpectatorTarget() then table.insert(potential, ent) end
	end
	for _, ent in ipairs(ents.FindByClass("planted_bomb")) do
		table.insert(potential, ent)
	end
	for _, ent in ipairs(ents.FindByClass("npc_hostage")) do
		table.insert(potential, ent)
	end
	for _, ent in ipairs(ents.FindByClass("prop_flag")) do
		table.insert(potential, ent)
	end

	return potential
end

function GM:SpectatorKeyPress(pl, key)
	if key == IN_ATTACK then
		self:CycleSpectatorTargets(pl)
	elseif key == IN_ATTACK2 then
		self:CycleSpectatorTargets(pl, true)
	elseif key == IN_JUMP then
		pl.SpectateInEye = not pl.SpectateInEye
		local target = pl:GetObserverTarget()
		if target and target:IsValid() and pl:GetObserverMode() ~= OBS_MODE_ROAMING then
			self:SetSpectatorTarget(pl, target)
		else
			self:CycleSpectatorTargets(pl)
		end
	end
end

function GM:SetSpectatorSlot(pl, slot)
	local potential = self:GetSpectatorTargets(pl, true)
	local target = potential[slot]
	if target and target:IsValid() and target:IsValidSpectatorTarget() then
		self:SetSpectatorTarget(pl, target)
	end
end

concommand.Add("setspectatorslot", function(pl, command, arguments)
	if pl:IsValid() and not pl:Alive() and pl:GetObserverMode() ~= OBS_MODE_NONE then
		local slot = tonumber(arguments[1] or 0) or 0
		GAMEMODE:SetSpectatorSlot(pl, slot)
	end
end)

function GM:CycleSpectatorTargets(pl, reverse)
	pl.StartSpectating = nil

	local potential = self:GetSpectatorTargets(pl)
	if #potential == 0 then
		self:SetSpectatorTarget(pl)
		return
	end

	local target = pl:GetObserverTarget()
	local isnext = pl:GetObserverMode() == OBS_MODE_ROAMING or not IsValid(target)
	for i = (reverse and #potential or 1), (reverse and 1 or #potential), (reverse and -1 or 1) do
		local ent = potential[i]
		if not ent then break end

		if isnext then
			self:SetSpectatorTarget(pl, ent)
			return
		elseif target == ent then
			isnext = true
		end
	end

	self:SetSpectatorTarget(pl)
end

function GM:PlayerDeathThink(pl)
	if pl.StartSpectating and pl.StartSpectating <= CurTime() then
		self:CycleSpectatorTargets(pl)
	end
end

function GM:OnDamagedByExplosion(pl, dmginfo)
end

function GM:SetUpCTF()
	-- A bit messy since we're using maps not designed for this gamemode.

	local tflagpoint
	local ctflagpoint

	local function CheckFlagPoint(ent)
		if ctflagpoint then
			if not tflagpoint then
				tflagpoint = ent:GetPos()
			end
		elseif not ctflagpoint then
			ctflagpoint = ent:GetPos()
		end
	end

	for _, ent in pairs(ents.FindByClass("info_target")) do
		local lowername = string.lower(ent:GetName())
		if lowername == "ctflagpoint" then
			ctflagpoint = ent:GetPos()
		elseif lowername == "tflagpoint" then
			tflagpoint = ent:GetPos()
		elseif lowername == "blueflagpoint" then
			CheckFlagPoint(ent)
		elseif lowername == "redflagpoint" then
			CheckFlagPoint(ent)
		elseif lowername == "yellowflagpoint" then
			CheckFlagPoint(ent)
		elseif lowername == "greenflagpoint" then
			CheckFlagPoint(ent)
		end
	end

	for _, ent in pairs(ents.FindByClass("blueflagpoint")) do
		CheckFlagPoint(ent)
	end

	for _, ent in pairs(ents.FindByClass("redflagpoint")) do
		CheckFlagPoint(ent)
	end

	for _, ent in pairs(ents.FindByClass("yellowflagpoint")) do
		CheckFlagPoint(ent)
	end

	for _, ent in pairs(ents.FindByClass("greenflagpoint")) do
		CheckFlagPoint(ent)
	end

	for _, ent in pairs(ents.FindByClass("flagspawn")) do
		if ent.BlueTeam then
			CheckFlagPoint(ent)
		elseif ent.RedTeam then
			CheckFlagPoint(ent)
		elseif ent.YellowTeam then
			CheckFlagPoint(ent)
		elseif ent.GreenTeam then
			CheckFlagPoint(ent)
		end
	end

	-- Found flag points, ready for CTF!
	if tflagpoint and ctflagpoint then
		local tflag = ents.Create("prop_flag")
		if tflag:IsValid() then
			tflag:SetPos(tflagpoint)
			tflag:Spawn()
			tflag:SetTeam(TEAM_T)
		end

		local ctflag = ents.Create("prop_flag")
		if ctflag:IsValid() then
			ctflag:SetPos(ctflagpoint)
			ctflag:Spawn()
			ctflag:SetTeam(TEAM_CT)
		end

		for _, wall in pairs(ents.FindByClass("func_wall_toggle")) do
			wall:Fire("toggle", "", 0)
		end
	end
end

function GM:InitPostEntityMap()
	MapEditorEntities = {}
	file.CreateDir("asmaps")
	if file.Exists("asmaps/"..game.GetMap()..".txt", "DATA") then
		for _, enttab in pairs(Deserialize(file.Read("asmaps/"..game.GetMap()..".txt", "DATA"))) do
			local ent = ents.Create(string.lower(enttab.Class))
			if ent:IsValid() then
				ent:SetPos(enttab.Position)
				ent:SetAngles(enttab.Angles)
				if enttab.KeyValues then
					for key, value in pairs(enttab.KeyValues) do
						ent[key] = value
					end
				end
				ent:Spawn()
				table.insert(MapEditorEntities, ent)
			end
		end
	end

	local ctspawns = {}
	local tspawns = {}

	-- Teamplay maps
	ctspawns = table.Add(ctspawns, ents.FindByClass("info_player_blue"))
	ctspawns = table.Add(ctspawns, ents.FindByClass("info_player_green"))
	tspawns = table.Add(tspawns, ents.FindByClass("info_player_red"))
	tspawns = table.Add(tspawns, ents.FindByClass("info_player_yellow"))
	for _, ent in pairs(ents.FindByClass("gmod_player_start")) do
		if ent.BlueTeam or ent.GreenTeam then
			table.insert(ctspawns, ent)
		elseif ent.RedTeam or ent.YellowTeam then
			table.insert(tspawns, ent)
		end
	end

	if #ctspawns == 0 then
		ctspawns = ents.FindByClass("info_player_counterterrorist")
		ctspawns = table.Add(ctspawns, ents.FindByClass("info_player_combine"))
	end
	if #tspawns == 0 then
		tspawns = ents.FindByClass("info_player_terrorist")
		tspawns = table.Add(tspawns, ents.FindByClass("info_player_rebel"))
	end

	if #ctspawns == 0 then
		ctspawns = table.Add(ctspawns, ents.FindByClass("info_player_start"))
	end
	if #tspawns == 0 then
		tspawns = table.Add(tspawns, ents.FindByClass("info_player_start"))
	end

	local overridet = ents.FindByClass("info_player_toverride")
	if #overridet > 0 then
		tspawns = overridet
	end

	local overridect = ents.FindByClass("info_player_ctoverride")
	if #overridect > 0 then
		ctspawns = overridect
	end

	local specspawns = table.Copy(specspawns, ctspawns)
	specspawns = table.Add(specspawns, tspawns)

	team.SetSpawnPoint(TEAM_CT, ctspawns)
	team.SetSpawnPoint(TEAM_T, tspawns)
	team.SetSpawnPoint(TEAM_SPECTATOR, specspawns)

	for _, ent in pairs(ents.FindByClass("hostage_entity")) do
		local host = ents.Create("npc_hostage")
		if host:IsValid() then
			host:SetPos(ent:GetPos())
			host:SetAngles(ent:GetAngles())
			host:Spawn()
		end
	end

	self:SetNumBombTargets(#ents.FindByClass("func_bomb_target"))
	self:SetNumHostages(#ents.FindByClass("hostage_entity"))
	self:SetUpCTF()
end

function GM:InitPostEntity()
	physenv.SetPerformanceSettings({MaxVelocity = 32000})

	RunConsoleCommand("sv_voiceenable", "1")
end

concommand.Add("mapeditor_add", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	if not arguments[1] then return end

	local tr = sender:TraceLine(3000)
	if tr.Hit then
		local ent = ents.Create(string.lower(arguments[1]))
		if ent:IsValid() then
			ent:SetPos(tr.HitPos)
			ent:Spawn()
			table.insert(MapEditorEntities, ent)
			SaveMapEditorFile()
		end
	end
end)

concommand.Add("mapeditor_addonme", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	if not arguments[1] then return end

	local ent = ents.Create(string.lower(arguments[1]))
	if ent:IsValid() then
		ent:SetPos(sender:EyePos())
		ent:Spawn()
		table.insert(MapEditorEntities, ent)
		SaveMapEditorFile()
	end
end)

concommand.Add("mapeditor_remove", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:TraceLine(3000)
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(MapEditorEntities) do
			if ent == tr.Entity then
				table.remove(MapEditorEntities, i)
				ent:Remove()
			end
		end
		SaveMapEditorFile()
	end
end)

local function ME_Pickup(pl, ent, uid)
	if pl:IsValid() and ent:IsValid() then
		ent:SetPos(util.TraceLine({start=pl:GetShootPos(),endpos=pl:GetShootPos() + pl:GetAimVector() * 3000, filter={pl, ent}}).HitPos)
		return
	end
	timer.Destroy(uid.."mapeditorpickup")
	SaveMapEditorFile()
end

concommand.Add("mapeditor_pickup", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local tr = sender:TraceLine(3000)
	if tr.Entity and tr.Entity:IsValid() then
		for i, ent in ipairs(MapEditorEntities) do
			if ent == tr.Entity then
				timer.CreateEx(sender:UniqueID().."mapeditorpickup", 0.25, 0, ME_Pickup, sender, ent, sender:UniqueID())
			end
		end
	end
end)

concommand.Add("mapeditor_drop", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	timer.Destroy(sender:UniqueID().."mapeditorpickup")
	SaveMapEditorFile()
end)

function SaveMapEditorFile()
	local sav = {}
	for _, ent in pairs(MapEditorEntities) do
		if ent:IsValid() then
			local enttab = {}
			enttab.Class = ent:GetClass()
			enttab.Position = ent:GetPos()
			enttab.Angles = ent:GetAngles()
			if ent.KeyValues then
				enttab.KeyValues = {}
				for _, key in pairs(ent.KeyValues) do
					enttab.KeyValues[key] = ent[key]
				end
			end
			table.insert(sav, enttab)
		end
	end
	file.Write("asmaps/"..game.GetMap()..".txt", Serialize(sav))
end

function GM:PlayerSwitchFlashlight(pl, onoff)
	return false
end

function GM:AllowPlayerPickup(pl, ent)
	return false
end

function GM:SetupPlayerVisibility(pl)
	local state = pl:GetState()
	if state == STATE_AWESOMERIFLEEND or state == STATE_AWESOMELAUNCHEREND then
		AddOriginToPVS(pl:GetStateVector())
	elseif state == STATE_AWESOMERIFLEGUIDE or state == STATE_AWESOMELAUNCHERGUIDE then
		local bullet = pl:GetStateEntity()
		if bullet:IsValid() then
			AddOriginToPVS(bullet:GetPos())
		end
	end
end

function GM:CleanUp()
	for _, ent in pairs(ents.GetAll()) do
		if ent.ShouldCleanUp or ent:IsProjectile() or ent:IsWeapon() and not ent:GetOwner():IsValid() then ent:Remove() end
	end

	game.CleanUpMap()
	gamemode.Call("InitPostEntityMap")
	for _, ent in pairs(ents.GetAll()) do
		if ent:IsWeapon() and ent:GetOwner():IsValid() and ent:GetOwner():GetActiveWeapon() == ent then
			ent:GiveWeaponStatus()
		end
	end

	--self:RemoveAllBullets()
end

function GM:StartRound()
	self:CheckKillStreaks()

	self.HostageBeingRescuedWarning = nil
	self:SetRoundEnded(false)
	self.roundstart = CurTime() + GetConVarNumber("as_freezetime")
	SetGlobalFloat("roundstart", self.roundstart)

	for _, ent in pairs(ents.FindByClass("hostage_entity")) do
		local host = ents.Create("npc_hostage")
		if host:IsValid() then
			host:SetPos(ent:GetPos())
			host:SetAngles(ent:GetAngles())
			host:Spawn()
		end
	end

	for _, pl in pairs(player.GetAll()) do
		if not pl.KeyPressedThisRound then
			if pl:Team() == TEAM_SPECTATOR then
				pl:AddNotice("You are currently spectating.", nil, COLID_WHITE)
				pl:AddNotice("Press F2 to join the match.", nil, COLID_WHITE)
			else
				pl:ChangeTeam(TEAM_SPECTATOR, true)
				pl:Spectate(OBS_MODE_ROAMING)
				pl:AddNotice("You have been made a spectator for being idle too long.", nil, COLID_WHITE)
			end
		elseif pl:Team() == TEAM_SPECTATOR then
			pl:AddNotice("Press F2 to join the match.", nil, COLID_WHITE)
		end
		pl.KeyPressedThisRound = nil
	end

	self:CleanUp()

	self.PlayerHeals = {}
	self.PlayerHealLimits = {}

	if self.BadJobAtScrambling then
		self.BadJobAtScrambling = self.BadJobAtScrambling - 1
		if self.BadJobAtScrambling <= 0 then
			self.BadJobAtScrambling = nil
		end
	end

	if self:ShouldScrambleTeams() and not self.BadJobAtScrambling then
		self:ScrambleTeams()
	elseif GetConVarNumber("as_balanceteams") ~= "0" then
		local ts = team.GetPlayers(TEAM_T)
		local tamount = #ts
		local cts = team.GetPlayers(TEAM_CT)
		local ctamount = #cts
		if tamount < ctamount - 1 then
			for i=1, ctamount - tamount - 1 do
				cts = team.GetPlayers(TEAM_CT)
				cts[math.random(1, #cts)]:ChangeTeam(TEAM_T, true)
			end
			self:AddNotice("Teams have been auto-balanced.", nil, COLID_WHITE)
		elseif ctamount < tamount - 1 then
			for i=1, tamount - ctamount - 1 do
				ts = team.GetPlayers(TEAM_T)
				ts[math.random(1, #ts)]:ChangeTeam(TEAM_CT, true)
			end
			self:AddNotice("Teams have been auto-balanced.", nil, COLID_WHITE)
		end
	end

	for _, pl in pairs(player.GetAll()) do
		pl:SetDiedThisRound(false)
		pl.ChangedSkillThisRound = nil
		pl.RevivedThisRound = nil
		pl.StartSpectating = nil
		pl.NumBuysThisRound = 0
		if pl.CanRescueHostage then
			pl.CanRescueHostage = nil
			pl:SendLua("CanRescueHostage=nil")
		end
		if pl.CanBuy then
			pl.CanBuy = nil
			pl:SendLua("CanBuy=nil")
		end
		if pl.CanPlantBomb then
			pl.CanPlantBomb = nil
			pl:SendLua("MySelf.CanPlantBomb=nil")
		end

		if pl:Team() == TEAM_T or pl:Team() == TEAM_CT then
			pl:Spawn()
			pl:Freeze(true)

			pl:SetDesiredSkill()
		end
	end

	for _, ent in pairs(ents.FindByClass("weapon_*")) do
		if ent.SetClip1 and ent.Primary then
			ent:SetClip1(ent.Primary.ClipSize)
		end
		if ent.SetClip2 and ent.Secondary then
			ent:SetClip2(ent.Secondary.ClipSize)
		end
	end

	gmod.BroadcastLua("gamemode.Call(\"StartRound\")")
end

local nextcheck = 0
function GM:Think()
	local ct = CurTime()

	for _, pl in pairs(player.GetAll()) do
		pl:Think()
	end

	if nextcheck <= ct then
		nextcheck = ct + 1

		self:CheckRoundStatus()
	end

	if self:GetRoundEnded() and self.roundstart <= ct then
		self:StartRound()
	elseif not self:GetRoundEnded() and self.roundstart <= ct then
		self.endroundtime = CurTime() + self:GetRoundTime()
		SetGlobalFloat("endroundtime", self.endroundtime)
		self.roundstart = math.huge

		local ran = math.random(1, 3)
		for _, pl in pairs(player.GetAll()) do
			if pl:Alive() and (pl:Team() == TEAM_T or pl:Team() == TEAM_CT) then
				pl:Freeze(false)
				if ran == 1 then
					pl:SendLua("surface.PlaySound(\"radio/letsgo.wav\")")
				elseif ran == 2 then
					pl:SendLua("surface.PlaySound(\"radio/locknload.wav\")")
				else
					pl:SendLua("surface.PlaySound(\"radio/moveout.wav\")")
				end

				pl:SetDesiredSkill()
			end
		end

		if self:GetNumBombTargets() > 0 then
			team.AddNotice(TEAM_T, "Bomb the target to win! Don't allow the bomb to be defused.", nil, COLID_RED)
			team.AddNotice(TEAM_CT, "Protect all targets from being bombed or defuse the bomb to win!", nil, COLID_RED)
		elseif self:GetNumHostages() > 0 then
			team.AddNotice(TEAM_T, "Don't allow the hostages to be rescued!", nil, COLID_RED)
			team.AddNotice(TEAM_CT, "Rescue all hostages to win!", nil, COLID_RED)
		elseif self:GetIsCTF() then
			self:AddNotice("Capture the enemy flag to win!", nil, COLID_RED)
		else
			self:AddNotice("Eliminate all highlighted enemy players to win!", nil, COLID_RED)
		end
	elseif self.endroundtime <= ct then
		if self:GetIsCTF() then
			local lastchance = false
			for _, e in pairs(ents.FindByClass("prop_flag")) do
				if e:GetState() ~= FLAGSTATE_HOME then
					lastchance = true
					break
				end
			end
			if not lastchance then
				self:EndRound(0, false, 3)
			end
		elseif 0 < self:GetNumBombTargets() then
			if #ents.FindByClass("planted_bomb") == 0 then
				self:EndRound(TEAM_CT, false, 1)
			end
			--[[local lastchance
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
			if not lastchance then
				self:EndRound(0, false, 2)
			end]]
		elseif 0 < self:GetNumHostages() then
			if 0 < #ents.FindByClass("npc_hostage") then
				local lastchance = false
				for _, e in pairs(ents.FindByClass("npc_hostage")) do
					if e:ShouldBeLastChance() then
						lastchance = true
						break
					end
				end
				if not lastchance then
					self:EndRound(TEAM_T, false, 1)
				end
			else
				self:EndRound(TEAM_CT, false, 1)
			end
		else -- FY map
			local numts = team.NumDidntDieThisRoundPlayers(TEAM_T) --team.NumAlivePlayers(TEAM_T)
			local numcts = team.NumDidntDieThisRoundPlayers(TEAM_CT) --team.NumAlivePlayers(TEAM_CT)
			if numts == numcts then
				self:EndRound(0, false, 2)
			elseif numts < numcts then
				self:EndRound(TEAM_CT, false, 2)
			else
				self:EndRound(TEAM_T, false, 2)
			end
		end
	end
end

function GM:PlayerSpray(pl)
	return not pl:Alive()
end

function GM:ShutDown()
end

function GM:CanPlayerSuicide(pl)
	return pl:Alive()
end

function GM:WeaponDeployed(pl, wep)
	if pl:IsValid() then
		RestoreSpeed(pl, wep.WalkSpeed)
		pl:CallStateFunction("WeaponDeployed", wep)
		pl:CallSkillFunction("WeaponDeployed", wep)
	end
end

function GM:PlayerInitialSpawn(pl)
	pl:SetMaxHealthEx(100)

	pl.NextPainSound = 0

	pl.LastDamaged = 0

	pl.NextWallJump = 0
	pl.NextDodge = 0
	pl.NextAirDodge = 0

	pl.LastKill = 0
	pl.NextHealthRegen = 0

	pl.FirstHitsThisLife = {}

	pl:SetEnergy(ENERGY_DEFAULT, ENERGY_DEFAULT_REGENERATION)
	pl:ChangeTeam(TEAM_SPECTATOR, true)
	pl:Spectate(OBS_MODE_ROAMING)
	pl:SetCanZoom(false)
	pl:SetCanWalk(false)
	pl:SetCrouchedWalkSpeed(0.44)
	pl:SetCombo(0)
	pl.JoinTime = CurTime()

	self:LoadWinStreak(pl)

	local saved = self.SavedStats[pl:UniqueID()]
	if saved then
		if saved[1] then
			pl:SetFrags(saved[1])
		end
		if saved[2] then
			pl:SetDeaths(saved[2])
		end
		if saved[3] then
			pl:SetKills(saved[3])
		end
	end
end

concommand.Add("changeteam", function(sender, command, arguments)
	if not sender:IsValid() or not sender:IsConnected() then return end

	sender.NextTeamChange = sender.NextTeamChange or 0

	if CurTime() < sender.NextTeamChange then
		sender:PrintMessage(HUD_PRINTTALK, "You must wait "..math.ceil(sender.NextTeamChange - CurTime()).." more seconds before changing teams.")
		return
	end

	local teamid = tonumber(arguments[1]) or 0
	if sender:Team() == teamid then return end

	if teamid == TEAM_SPECTATOR then
		sender.NextTeamChange = math.max(sender.NextTeamChange, CurTime() + 5)
		if sender:Alive() then
			sender:Kill()
		end
		sender:ChangeTeam(teamid)
		GAMEMODE:CheckRoundStatus()
	elseif teamid == TEAM_T then
		local numts = team.NumPlayers(TEAM_T)
		local numcts = team.NumPlayers(TEAM_CT)
		if GetConVarNumber("as_eventeams") == 0 or (numcts == 0 or numts < numcts + GetConVarNumber("as_autobalancethresh")) and not (numcts == 0 and 0 < numts) then
			sender.NextTeamChange = CurTime() + 90
			sender:StripWeapons()
			if sender:Alive() then
				sender:Kill()
			end
			sender:ChangeTeam(TEAM_T)
			GAMEMODE:CheckRoundStatus()
		else
			sender:PrintMessage(HUD_PRINTTALK, "That would make the teams unfair!")
			GAMEMODE:ShowTeam(sender)
			sender.NextTeamChange = CurTime() + 0.2
		end
	elseif teamid == TEAM_CT then
		local numts = team.NumPlayers(TEAM_T)
		local numcts = team.NumPlayers(TEAM_CT)
		if GetConVarNumber("as_eventeams") == 0 or (numts == 0 or numcts < numts + GetConVarNumber("as_autobalancethresh")) and not (numts == 0 and 0 < numcts) then
			sender.NextTeamChange = CurTime() + 90
			sender:StripWeapons()
			if sender:Alive() then
				sender:Kill()
			end
			sender:ChangeTeam(TEAM_CT)
			GAMEMODE:CheckRoundStatus()
		else
			sender:PrintMessage(HUD_PRINTTALK, "That would make the teams unfair!")
			GAMEMODE:ShowTeam(sender)
			sender.NextTeamChange = CurTime() + 0.2
		end
	end
end)

concommand.Add("changeskill", function(sender, command, arguments)
	if not sender:IsValid() or not sender:IsConnected() or not sender.CanBuy then return end

	local skillid = arguments[1]
	if not skillid then return end
	skillid = tonumber(skillid)
	if not skillid or not SKILLS[skillid] then return end

	if GAMEMODE.roundstart == math.huge then
		if sender.ChangedSkillThisRound then
			sender:AddNotice("You can only change your skill once per round!", nil, COLID_RED)
		else
			sender.ChangedSkillThisRound = true
			sender:SetSkill(skillid)
		end
	end
end)

function GM:PlayerLoadout(pl)
	pl:StripWeapons()
	pl:GiveValidLoadout()
end

function GM:PlayerSpawn(pl)
	local plteam = pl:Team()
	if plteam == TEAM_SPECTATOR then
		pl:Spectate(OBS_MODE_ROAMING)
		return
	end

	pl:UnSpectate()
	pl:RemoveTomb()

	pl:EndState()
	pl:SetLocalVelocity(Vector(0, 0, 0))
	pl:ResetJumpPower()
	pl:SetNoCollideWithTeammates(true)
	pl:SetAvoidPlayers(true)
	pl:ShouldDropWeapon(false)
	pl:SetGravity(GRAVITY_DEFAULT)
	pl:ClearLastAttacker()
	pl:SetEnergy(ENERGY_DEFAULT, ENERGY_DEFAULT_REGENERATION, true)
	pl:SetDesiredSkill()

	pl.FirstHitsThisLife = {}

	--self:SetPlayerSpeed(pl, 200, 100)

	self:PlayerLoadout(pl)

	local desiredname = pl:GetInfo("cl_playermodel")
	local modelname = player_manager.TranslatePlayerModel(#desiredname == 0 and "kleiner" or desiredname)
	pl:SetModel(modelname)

	pl:RefreshVoiceSet()

	local myteam = pl:Team()
	local isplaying = myteam == TEAM_T or myteam == TEAM_CT

	if self.roundstart ~= math.huge and CurTime() < self.roundstart and isplaying then
		pl:Freeze(true)
	end

	pl:CallSkillFunction("PlayerSpawn")
end

function GM:PlayerReady(pl)
	if pl:IsValid() then
		self:ShowTeam(pl)
	end
end

function GM:ShowTeam(pl)
	pl:SendLua("GAMEMODE:ShowTeam()")
end

function GM:ShowHelp(pl)
	pl:SendLua("GAMEMODE:ShowHelp()")
end

function GM:ShowSpare1(pl)
	pl:SendLua("GAMEMODE:ShowSpare1()")
end

function GM:ShowSpare2(pl)
	--pl:SendLua("GAMEMODE:ToggleRadio()")
end

function gmod.BroadcastLua(lu)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(lu)
	end
end

function GM:ZoneCaptured(teamid)
	local snd = teamid == TEAM_T and "weapons/c4/c4_plant.wav" or "weapons/c4/c4_disarm.wav"

	team.AddNotice(TEAM_SPECTATOR, "Bomb site captured by "..team.GetName(teamid).."!~s"..snd, 7, teamid == TEAM_T and COLID_RED or COLID_BLUE)
	team.AddNotice(teamid == TEAM_T and TEAM_T or TEAM_CT, "We have captured a bomb site!~s"..snd, 7, COLID_GREEN)
	team.AddNotice(teamid == TEAM_T and TEAM_CT or TEAM_T, "Bomb site captured by the enemy!~s"..snd, 7, COLID_RED)

	local holder = self:GetCaptureHolders()
	if holder == TEAM_T then
		team.AddNotice(TEAM_SPECTATOR, "Terrorists have armed the bombs!!~sradio/bombpl.wav", 7, COLID_RED)
		team.AddNotice(TEAM_T, "Terrorists have armed the bombs!!~sradio/bombpl.wav", 7, COLID_GREEN)
		team.AddNotice(TEAM_CT, "Terrorists have armed the bombs!!~sradio/bombpl.wav", 7, COLID_RED)
	elseif holder == TEAM_CT then
		team.AddNotice(TEAM_SPECTATOR, "Counter-terrorists are defusing the bombs!!~sambient/machines/keyboard_fast3_1second.wav", 7, COLID_BLUE)
		team.AddNotice(TEAM_T, "Counter-terrorists are defusing the bombs!!~sambient/machines/keyboard_fast3_1second.wav", 7, COLID_RED)
		team.AddNotice(TEAM_CT, "Counter-terrorists are defusing the bombs!!~sambient/machines/keyboard_fast3_1second.wav", 7, COLID_GREEN)
	end
end

function GM:EndRound(winner, nosoundormessage, reason)
	if self:GetRoundEnded() then return end

	self:SetRoundEnded(true)

	for _, ent in pairs(ents.FindByClass("weapon_as_bomb")) do
		ent:Remove()
	end

	if not nosoundormessage then
		if winner == TEAM_T then
			if reason == 1 then
				self:AddNotice("Counter-terrorists failed to rescue the hostages!", 7)
			elseif reason == 2 then
				self:AddNotice("The round ended with more terrorists untagged!", 7)
			elseif reason == 4 then
				self:AddNotice("Terrorists successfully bombed the targets!", 7)
			end

			self:AddNotice("Terrorists win!~sradio/terwin.wav", 7, COLID_RED)
		elseif winner == TEAM_CT then
			if reason == 1 then
				self:AddNotice("Terrorists failed to bomb a target!", 7)
			elseif reason == 2 then
				self:AddNotice("The round ended with more counter-terrorists untagged!", 7)
			elseif reason == 3 then
				self:AddNotice("All hostages have been rescued!", 7)
			end

			if reason == 4 then
				self:AddNotice("Counter-terrorists defused the bombs!~sradio/bombdef.wav", 7, COLID_BLUE)
			else
				self:AddNotice("Counter-terrorists win!~sradio/ctwin.wav", 7, COLID_BLUE)
			end
		else
			if reason == 2 then
				self:AddNotice("ROUND DRAW!~sradio/rounddraw.wav")
			elseif reason == 3 then
				self:AddNotice("NO ONE CAPTURED A FLAG!~sradio/rounddraw.wav")
			else
				self:AddNotice("GAME START!~sradio/rounddraw.wav")
			end
		end
	end

	self:CheckWinStreaks(winner)

	local numts = team.NumPlayers(TEAM_T)
	local numcts = team.NumPlayers(TEAM_CT)
	for _, pl in pairs(player.GetAll()) do
		if pl:Team() == winner then
			if winner == TEAM_T and 0 < numcts or winner == TEAM_CT and 0 < numts then
				pl:AddPoints(5)
			end
		elseif winner ~= 0 and 1 < numcts and 1 < numts and pl:Team() ~= TEAM_SPECTATOR then
			pl:AddPoints(1)
		end
	end

	self:SetRound(self:GetRound() + 1)

	if self:GetNumRounds() <= self:GetRound() then
		gamemode.Call("EndGame")
	else
		self.roundstart = CurTime() + GetConVarNumber("as_intermissiontime")
		SetGlobalFloat("roundstart", self.roundstart)

		self.endroundtime = self.roundstart + GetConVarNumber("as_freezetime") + self:GetRoundTime()
		SetGlobalFloat("endroundtime", self.endroundtime)

		if self:ShouldScrambleTeams() then
			self:AddNotice("Teams are being scrambled next round.~sambient/alarms/warningbell1.wav")
		end
	end

	gamemode.Call("PostEndRound", winner, nosoundormessage, reason)
end

function GM:PostEndRound(winner, nosoundormessage, reason)
end

function GM:EndGame()
	if self.GameEnded then return end
	self.GameEnded = true

	self:SaveWinStreaks()

	for _, pl in pairs(player.GetAll()) do
		pl:Freeze(true)
		pl:GodEnable()
	end

	umsg.Start("EndG")
		umsg.Short(winner)
	umsg.End()

	hook.Add("PlayerSpawn", "FREEZENEW", function(p)
		p:Freeze(true)
		p:GodEnable()
	end)

	GAMEWINNER = winner
	hook.Add("PlayerReady", "FREEZENEW2", function(p)
		umsg.Start("EndG", p)
			umsg.Short(GAMEWINNER)
		umsg.End()
	end)

	gamemode.Call("PostEndGame")

	gamemode.Call("LoadNextMap")
end

function GM:LoadNextMap()
	timer.Simple(30, game.LoadNextMap)
end

function GM:PostEndGame()
end

concommand.Add("initpostentity", function(sender, command, arguments)
	if not sender.DidInitPostEntity then
		sender.DidInitPostEntity = true

		gamemode.Call("PlayerReady", sender)
	end
end)

function GM:PlayerSelectSpawn(pl)
	local tab = team.GetSpawnPoint(pl:Team()) or {}
	local Count = #tab
	if Count == 0 then return pl end
	local ChosenSpawnPoint = tab[1]
	for i=0, 20 do
		ChosenSpawnPoint = tab[math.random(1, Count)]
		if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() then
			local blocked = false
			for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-16, -16, 0), ChosenSpawnPoint:GetPos() + Vector(16, 16, 72))) do
				if ent:IsPlayer() then
					blocked = true
				end
			end
			if not blocked then
				return ChosenSpawnPoint
			end
		end
	end

	return ChosenSpawnPoint
end

function GM:PlayerDeathSound(pl)
	return true
end

function GM:PlayerDeath(Victim, Inflictor, Attacker)
end

function GM:CheckRoundStatus()
	local tcount = 0
	local ctcount = 0

	local allplayers = player.GetAll()
	for _, pl in pairs(allplayers) do
		if pl:Team() == TEAM_T then
			tcount = tcount + 1
		elseif pl:Team() == TEAM_CT then
			ctcount = ctcount + 1
		end
	end

	if self:GetRound() == 0 then
		if tcount == 0 or ctcount == 0 then return end

		self:EndRound(0)
	--[[elseif 0 < self:GetNumBombTargets() then
		local holder = self:GetCaptureHolders()
		if holder > 0 and CurTime() >= self:GetCaptureEndTime() then
			for _, ent in pairs(ents.FindByClass("point_capturezone")) do
				if ent:ShouldBeLastChance() then
					return
				end
			end

			self:EndRound(holder, false, 4)

			for _, ent in pairs(ents.FindByClass("point_capturezone")) do
				if holder == TEAM_T then
					ent:Explode()
				end
				ent:SetNoDraw(true)
			end
		end]]
	elseif not self:MapHasObjective() then
		if tcount == 0 or ctcount == 0 then return end

		local didntdiet = team.NumDidntDieThisRoundPlayers(TEAM_T)
		local didntdiect = team.NumDidntDieThisRoundPlayers(TEAM_CT)
		if didntdiet == 0 then
			if didntdiect == didntdiet then
				self:EndRound(0)
			else
				self:EndRound(TEAM_CT)
			end
		elseif didntdiect == 0 then
			self:EndRound(TEAM_T)
		end
	end
end

function GM:AddedPoints(pl, points)
end

GM.PlayerHeals = {}
GM.PlayerHealLimits = {}
function GM:PlayerHeal(pl, other, amount)
	local prevhealth = other:Health()

	if pl:GetSkill() == SKILL_MEDICALMASTERY then
		other:SetHealth(math.min(other:GetMaxHealthEx(), prevhealth + amount * 2))
	else
		other:SetHealth(math.min(other:GetMaxHealthEx(), prevhealth + amount))
	end

	local deltahealth = other:Health() - prevhealth
	if deltahealth <= 0 then return end

	if pl == other then return end

	local pluid = pl:UniqueID()
	local otheruid = other:UniqueID()

	self.PlayerHealLimits[pluid] = self.PlayerHealLimits[pluid] or {}
	local lim = self.PlayerHealLimits[pluid]
	lim[otheruid] = lim[otheruid] or 0

	if lim[otheruid] < 200 then
		lim[otheruid] = lim[otheruid] + amount
	else
		return
	end

	self.PlayerHeals[pluid] = (self.PlayerHeals[pluid] or 0) + amount
	if self.PlayerHeals[pluid] >= 75 then
		self.PlayerHeals[pluid] = self.PlayerHeals[pluid] - 75
		pl:AddPoints(1)
	end
end

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	local inflictor = dmginfo:GetInflictor()
	local inflictorisself = inflictor == attacker or not inflictor:IsValid()
	if inflictorisself then
		local lastattacker = pl:GetLastAttacker()
		if lastattacker:IsValid() then
			attacker = lastattacker
			inflictorisself = false
		end
	end
	local owner = attacker:GetOwner()
	if owner:IsValid() then attacker = owner end

	local state = pl:GetState()
	pl:EndState()
	if pl:FlashlightIsOn() then
		pl:Flashlight(false)
	end

	pl.StartSpectating = CurTime() + 4

	timer.SimpleEx(0, gamemode.Call, "CheckRoundStatus")

	pl:Freeze(false)
	pl:AddDeaths(1)

	if not pl:CallStateFunction("DontCreateRagdoll", dmginfo) then
		pl:CreateRagdoll()
	end
	pl:RemoveAllStatus(true, true)
	pl:PlayDeathSound()

	local dmgtype = dmginfo:GetDamageType()
	if dmgtype == DMG_BLAST or dmgtype == DMG_BURN or dmgtype == DMG_SLOWBURN or dmgtype == DMG_DIRECT then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:EyePos())
			effectdata:SetEntity(pl)
		util.Effect("fire_death", effectdata)
	elseif dmgtype == DMG_SHOCK then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:EyePos())
			effectdata:SetEntity(pl)
		util.Effect("electric_death", effectdata)
	elseif dmgtype == DMG_DROWN then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:EyePos())
			effectdata:SetEntity(pl)
		util.Effect("ice_death", effectdata)
	end

	local attackerisaplayerbutnotme = attacker ~= pl and attacker:IsPlayer()

	if attackerisaplayerbutnotme then attacker.RecordingKillTypes = true end
	local maintype, subtypes = self:GetKillMessageTypes(pl, attacker, inflictor, dmginfo, state)
	if attackerisaplayerbutnotme then attacker.RecordingKillTypes = nil end

	if attackerisaplayerbutnotme then
		attacker:AddPoints((self.KillActionBasePoints[maintype] or self.KillActionBasePoints[KILLACTION_GENERIC]) + self:GetKillAction2Points(subtypes))
		attacker:AddKills(1)
		attacker:AllowImmediateDecalPainting()
	end

	local diedthisround = pl:GetDiedThisRound()
	pl:SetDiedThisRound(true)

	if not diedthisround and not self:MapHasObjective() and team.NumDidntDieThisRoundPlayers(pl:Team()) == 1 then
		self:AddNotice(team.GetName(pl:Team()).." have one untagged player remaining!", nil, COLID_RED)
	end

	if attacker:IsValid() and attacker:IsPlayer() then
		PrintMessage(HUD_PRINTCONSOLE, attacker:Name().." killed "..pl:Name()..".")
	else
		PrintMessage(HUD_PRINTCONSOLE, pl:Name().." died.")
	end

	pl:SpawnTomb(maintype == KILLACTION_ENVIRONMENT, attacker)

	umsg.Start("AwesomeStrikePlayerKilled")
		umsg.Entity(pl)
		umsg.Entity(attacker)
		umsg.Short(maintype)
		umsg.Long(subtypes)
	umsg.End()

	if attacker ~= pl and attacker:IsPlayer() then
		gamemode.Call("AddKillStreak", attacker, inflictor, maintype)
	end

	self:EndKillStreak(pl, attacker)

	gamemode.Call("PostDoPlayerDeath", pl, attacker, inflictor, dmginfo, maintype, subtypes)
end

function GM:PostDoPlayerDeath(pl, attacker, inflictor, dmginfo, maintype, subtypes)
end

function GM:GetKillMessageTypes(pl, attacker, inflictor, dmginfo, plstate)
	local maintype = KILLACTION_GENERIC
	local subtypes = 0

	if inflictor:IsValid() then
		local overridea, overrideb = inflictor.GetKillAction and inflictor:GetKillAction(pl, attacker, dmginfo, plstate)
		if overridea then
			maintype = overridea
		end
		if overrideb then
			subtypes = bit.bor(subtypes, overrideb)
		end
	end

	if maintype == KILLACTION_GENERIC then
		maintype = self:GetKillMessageMainType(pl, attacker, inflictor, dmginfo, plstate)
	end

	subtypes = bit.bor(subtypes, self:GetKillMessageSubTypes(pl, attacker, inflictor, dmginfo, maintype, plstate))

	return maintype, subtypes
end

function GM:GetKillMessageMainType(pl, attacker, inflictor, dmginfo, plstate)
	if inflictor:IsValid() and string.sub(inflictor:GetClass(), 1, 12) == "trigger_hurt" then
		return KILLACTION_ENVIRONMENT
	else
		local dmgtype = dmginfo:GetDamageType()
		if dmgtype == DMG_BULLET or dmgtype == DMG_BUCKSHOT then
			return KILLACTION_BULLET
		elseif dmgtype == DMG_SLASH then
			return KILLACTION_SLASH
		elseif dmgtype == DMG_CRUSH then
			if inflictor._doorsmash and CurTime() <= inflictor._doorsmash then
				return KILLACTION_DOORSMASH
			end

			return KILLACTION_PHYSICS
		elseif dmgtype == DMG_BURN or dmgtype == DMG_SLOWBURN or dmgtype == DMG_DIRECT then
			return KILLACTION_BURN
		elseif dmgtype == DMG_BLAST then
			return KILLACTION_EXPLOSION
		elseif dmgtype == DMG_CLUB then
			return KILLACTION_BASH
		elseif dmgtype == DMG_SHOCK then
			return KILLACTION_SHOCK
		elseif dmgtype == DMG_DROWN then
			return KILLACTION_FREEZE
		elseif dmgtype == DMG_DISSOLVE or dmgtype == DMG_ACID then
			return KILLACTION_DISSOLVE
		end
	end

	return KILLACTION_GENERIC
end

function GM:GetKillMessageSubTypes(pl, attacker, inflictor, dmginfo, maintype, plstate)
	local action = 0

	if attacker:IsValid() and attacker:IsPlayer() and attacker ~= pl then
		if TEMPBULLET then
			if TEMPBULLET.ForceShielded then action = bit.bor(action, KILLACTION2_DEFLECTED) end
			if TEMPBULLET.BulletBounceTimes and TEMPBULLET.BulletBounceTimes > 0 then action = bit.bor(action, KILLACTION2_BULLETBOUNCE) end
		end

		local state = inflictor._attackerstate or attacker:GetState()
		if state == STATE_SLIDE then
			action = bit.bor(action, KILLACTION2_SLIDE)
		elseif state == STATE_WALLRUN then
			action = bit.bor(action, KILLACTION2_WALLRUN)
		end

		if state == STATE_WALLJUMP or attacker.WallJumpInAir then
			action = bit.bor(action, KILLACTION2_WALLJUMP)
		end

		if attacker:GetPos():Distance(pl:GetPos()) >= 2048 then
			action = bit.bor(action, KILLACTION2_DISTANT)
		end

		if not attacker:Alive() then
			action = bit.bor(action, KILLACTION2_FROMTHEGRAVE)
		end

		if attacker.LastFullCloak and CurTime() <= attacker.LastFullCloak + 2 then
			action = bit.bor(action, KILLACTION2_GHOST)
		end

		if attacker.LastBlinkExit and CurTime() <= attacker.LastBlinkExit + 2 then
			action = bit.bor(action, KILLACTION2_BLINK)
		end

		if attacker:GetVelocity():Length() >= 768 then
			action = bit.bor(action, KILLACTION2_FLYBY)
		end

		if pl.FirstHitsThisLife[attacker] and CurTime() <= pl.FirstHitsThisLife[attacker] + 2 then
			action = bit.bor(action, KILLACTION2_EFFICIENT)
		end

		if plstate == STATE_KNOCKEDDOWN and not pl:GetToGroundTrace(128).Hit and not (inflictor:IsValid() and inflictor:GetClass() == "trigger_hurt") then
			action = bit.bor(action, KILLACTION2_JUGGLE)
		end

		if plstate == STATE_SEIZURE then
			action = bit.bor(action, KILLACTION2_SEIZURESLAYER)
		end

		if attacker.RecordingKillTypes then
			if CurTime() <= attacker.LastKill + 3 then
				attacker.KillCombo = attacker.KillCombo + 1
				if attacker.KillCombo == 2 then
					action = bit.bor(action, KILLACTION2_2XKILL)
				elseif attacker.KillCombo == 3 then
					action = bit.bor(action, KILLACTION2_3XKILL)
				elseif attacker.KillCombo == 4 then
					action = bit.bor(action, KILLACTION2_4XKILL)
				elseif attacker.KillCombo >= 5 then
					action = bit.bor(action, KILLACTION2_5XKILL)
				end
			else
				attacker.KillCombo = 1
			end

			attacker.LastKill = CurTime()
		end

		if mainaction ~= KILLACTION_ENVIRONMENT then
			if bit.band(action, KILLACTION2_WALLJUMP) == 0 and not attacker:OnGround() and not attacker:GetToGroundTrace(220).Hit then
				action = bit.bor(action, KILLACTION2_MIDAIR)
			end

			if not pl:OnGround() and not pl:GetToGroundTrace(220).Hit and not (inflictor:IsValid() and inflictor:GetClass() == "trigger_hurt") then
				action = bit.bor(action, KILLACTION2_ANTIAIR)
			end
		end
	end

	return action
end

GM.SavedStats = {}
function GM:PlayerDisconnect(pl)
	timer.SimpleEx(0.1, gamemode.Call, "CheckRoundStatus")

	if pl:Health() >= 1 and pl:Team() ~= TEAM_SPECTATOR then
		local lastattacker = pl:GetLastAttacker()
		if lastattacker:IsValid() then
			pl:TakeDamage(1000, lastattacker, lastattacker)
		end
	end

	pl:RemoveAllStatus(true, true)
	pl:RemoveAllProjectiles()
	pl:RemoveTomb()

	self:EndWinStreak(pl)
	self:EndKillStreak(pl)

	self.SavedStats[pl:UniqueID()] = {pl:Frags(), pl:Deaths(), pl:Kills()}
end

function GM:PlayerHurt(pl, attacker, healthremaining, damage)
	local isotherplayer = attacker:IsPlayer() and attacker ~= pl
	if isotherplayer then
		pl:SetLastAttacker(attacker)

		if not pl.FirstHitsThisLife[attacker] then
			pl.FirstHitsThisLife[attacker] = CurTime()
		end

		attacker:AddCombo(true)
	end

	if damage > 0 then
		pl.LastDamaged = CurTime()
	end

	if healthremaining > 0 then
		pl:PlayPainSound()
	end
end

function GM:PlayerUse(pl, ent)
	if not pl:Alive() then return false end

	if ent:GetClass() == "npc_hostage" and ent.NextPlayerUse <= CurTime() and pl:Team() == TEAM_CT
	and not ent:GetCarry():IsValid() and pl:IsIdle() and pl:GetState() ~= STATE_CARRYHOSTAGE
	and pl:OnGround() and ent:NearestPoint(pl:GetPos()):Distance(pl:GetPos()) <= 24 then
		ent.NextPlayerUse = CurTime() + 0.25

		ent:StartCarry(pl)

		if not self.HostageBeingRescuedWarning then
			self.HostageBeingRescuedWarning = true
			team.AddNotice(TEAM_T, "Warning! Hostages are being rescued!~sradio/hostagecompromised.wav", nil, COLID_RED)
		end
	end

	return true
end

function GM:GetFallDamage(pl, fallspeed)
	return 0
end

function GM:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()

	if attacker == inflictor and attacker:IsProjectile() and dmginfo:GetDamageType() == DMG_CRUSH then -- Fixes projectiles doing physics-based damage.
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
		return
	end

	if ent.ProcessDamage then
		ent:ProcessDamage(dmginfo)
	end
end

function GM:CreateEntityRagdoll(ent, ragdoll)
end

function GM:PlayerCanPickupWeapon(pl, entity)
	if string.sub(string.lower(entity:GetClass()), 1, 10) ~= "weapon_as_" then
		-- It's not even a weapon for this gamemode!
		entity:Remove()
		return false
	end

	if entity.Slot and entity.Slot == 0 then
		local num0s = 0
		for _, wep in pairs(pl:GetWeapons()) do
			if wep.Slot == 0 then
				num0s = num0s + 1
				if num0s >= 3 then
					return false
				end
			end
		end
	end

	return not (entity.TOnly and pl:Team() == TEAM_CT) and not (entity.CTOnly and pl:Team() == TEAM_T)
end

function RestoreSpeed(pl, speed)
	if not pl:IsValid() then return end

	if pl.Stunned then
		GAMEMODE:SetPlayerSpeed(pl, 1, 1)
	else
		speed = speed or 200
		if pl:GetSkill() == SKILL_SPEEDMASTERY then
			speed = speed + 50
		end
		GAMEMODE:SetPlayerSpeed(pl, speed, math.min(speed, 100))
	end
end

function IsGuardStun(owner, ent)
	return ent:IsPlayer() and (owner:IsPlayer() and owner:Team() ~= ent:Team() or not owner:IsPlayer()) and ent:GetActiveWeapon().Guarding and 1.4 < owner:GetForward():Distance(ent:GetForward())
end

function Guarded(hitter, guarder, duration)
	local wep = guarder:GetActiveWeapon()
	if wep:IsValid() and wep.Guarded then
		wep:Guarded(hitter, guarder, duration)
	end
end

concommand.Add("dropweapon", function(sender, command, arguments)
	local wep = sender:GetActiveWeapon()
	if wep:IsValid() and not wep:IsBusy() and wep:Holster() ~= false and not wep.Undroppable then
		if wep:GetClass() == "weapon_as_hostage" then
			local hostage = sender:GetStateEntity()
			if hostage:IsValid() and hostage:GetClass() == "npc_hostage" then
				hostage:EndCarry()
			end
			sender:StripWeapon(wep:GetClass())
		else
			sender:DropWeaponEx(wep)
		end
	end
end)

--[[function GM:CalcView()
end
GM.Think = GM.CalcView
GM.CreateMove = GM.CalcView
GM.Move = GM.CalcView
GM.AdjustMouseSensitivity = GM.CalcView
GM.SetupPlayerVisibility = GM.CalcView]]
