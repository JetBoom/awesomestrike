function GM:SaveWinStreaks()
	for _, pl in pairs(player.GetAll()) do
		self:SaveWinStreak(pl)
	end
end

function GM:SaveWinStreak(pl)
	local filename = "awesomestrike/winstreaks/"..pl:UniqueID()..".txt"
	if pl.WinStreak and pl.WinStreak >= 1 then
		file.Write(filename, tostring(pl.WinStreak)..","..os.time())
	elseif file.Exists(filename, "DATA") then
		file.Delete(filename)
	end
end

function GM:LoadWinStreak(pl)
	local filename = "awesomestrike/winstreaks/"..pl:UniqueID()..".txt"
	if file.Exists(filename, "DATA") then
		local contents = file.Read(filename, "DATA")
		if contents then
			local streak, time = string.match(contents, "(%d+),(%d+)")
			if streak and time then
				streak = tonumber(streak)
				if streak then
					pl.WinStreak = tonumber(streak or 0) or 0
					if pl.WinStreak == 0 then pl.WinStreak = nil end
				end
			end
		end
	end
end

function GM:EndWinStreak(pl)
	local filename = "awesomestrike/winstreaks/"..pl:UniqueID()..".txt"
	if file.Exists(filename, "DATA") then
		file.Delete(filename)
	end

	if pl.WinStreak then
		if pl.WinStreak >= 1 then
			gamemode.Call("WinStreakEnded", pl, pl.WinStreak)
		end
		pl.WinStreak = nil
	end
end
GM.DeleteWinStreak = GM.EndWinStreak

function GM:AddWinStreak(pl)
	pl.WinStreak = (pl.WinStreak or 0) + 1

	if pl.WinStreak >= 2 then
		self:SaveWinStreak(pl)
		gamemode.Call("WinStreak", pl, pl.WinStreak)
	end
end

function GM:AddKillStreak(pl, inflictor, maintype)
	pl.KillStreak = (pl.KillStreak or 0) + 1
	if pl.KillStreak == 1 then
		pl.KillStreakMainType = maintype
	elseif pl.KillStreakMainType ~= maintype and maintype ~= KILLACTION_GENERIC then
		pl.KillStreakMainType = nil
	end

	self:CheckKillStreak(pl, true)

	gamemode.Call("PostAddKillStreak", pl, inflictor, maintype, pl.KillStreak, pl.KillStreakMainType)
end

function GM:GetKillStreak(pl)
	return pl.KillStreak or 0
end

function GM:PostAddKillStreak(pl, inflictor, maintype, streak, streakmaintype)
end

function GM:CheckKillStreaks()
	for _, pl in pairs(player.GetAll()) do self:CheckKillStreak(pl) end
end

function GM:CheckKillStreak(pl, onlyatfive)
	if pl.KillStreak and pl.KillStreak >= 5 then
		if not onlyatfive or pl.KillStreak % 5 == 0 and pl.KillStreak >= 5 then
			local message
			if pl.KillStreakMainType then
				message = pl:Name().." is on a kill streak of "..pl.KillStreak.." ("..self:KillMessageMainTypeToString(pl.KillStreakMainType)..")!"
			else
				message = pl:Name().." is on a kill streak of "..pl.KillStreak.."!"
			end
			self:AddNotice(message, 4, COLID_WHITE)
		end
	end
end

function GM:EndKillStreak(pl, attacker)
	local streak = pl.KillStreak
	if streak and streak >= 5 then
		if attacker and attacker ~= pl and attacker:IsValid() and attacker:IsPlayer() then
			self:AddNotice(pl:Name().." had their kill streak of "..streak.." ended by "..attacker:Name().."!", 4, COLID_WHITE)
			attacker:AddPoints(math.floor(streak / 5))
		else
			self:AddNotice(pl:Name().." had their kill streak of "..streak.." ended!", 4, COLID_WHITE)
		end
	end

	pl.KillStreak = nil
	pl.KillStreakMainType = nil

	gamemode.Call("PostEndKillStreak", pl, attacker, streak)
end

function GM:PostEndKillStreak(pl, attacker, streak)
end

function GM:CheckWinStreaks(winner)
	if winner == TEAM_T or winner == TEAM_CT then
		for _, pl in pairs(player.GetAll()) do
			if pl:Team() == winner then
				self:AddWinStreak(pl)
			elseif pl:Team() ~= TEAM_SPECTATOR then
				self:EndWinStreak(pl)
			end
		end
	end
end

function GM:RecycleOldWinStreaks()
	local ostime = os.time()
	for _, filename in pairs(file.Find("awesomestrike/winstreaks/*.txt", "DATA")) do
		local fullfilename = "awesomestrike/winstreaks/"..filename
		local contents = file.Read(fullfilename, "DATA")
		if contents then
			local streak, time = string.match(contents, "(%d+),(%d+)")
			if streak and time then
				time = tonumber(time)
				if time and ostime < time + 86400 then
					continue
				end
			end
		end

		file.Delete(fullfilename)
	end
end

function GM:WinStreak(pl, streak)
	if streak >= 5 then
		self:AddNotice(pl:Name().." is on a win streak of "..streak.."!", 4, COLID_WHITE)
	end
end

function GM:WinStreakEnded(pl, streak)
	if streak >= 5 then
		self:AddNotice(pl:Name().."'s win streak of "..streak.." was ended!", 4, COLID_RED)
	end
end

function GM:IsOnWinStreak(pl)
	return pl.WinStreak and pl.WinStreak >= 5
end

function GM:IsOnKillStreak(pl)
	return pl.KillStreak and pl.KillStreak >= 5
end

function GM:IsOnStreak(pl)
	return self:IsOnWinStreak(pl) or self:IsOnKillStreak(pl)
end
