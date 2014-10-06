TEAM_CT = 2
TEAM_T = 3

team.SetUp(TEAM_CT, "Counter-Terrorists", Color(50, 90, 255, 255))
team.SetUp(TEAM_T, "Terrorists", Color(255, 30, 30, 255))
team.SetUp(TEAM_SPECTATOR, "Spectators", Color(160, 160, 160, 255))

function team.AddNotice(teamid, message, lifetime, color)
	local filter = RecipientFilter()
	filter:RemoveAllPlayers()
	for _, pl in pairs(team.GetPlayers(teamid)) do
		filter:AddPlayer(pl)
	end
	GAMEMODE:AddNotice(message, lifetime, color, filter)
end

function team.TotalKills(teamid)
	local count = 0

	for _, pl in pairs(team.GetPlayers(teamid)) do
		count = count + pl:Kills()
	end

	return count
end

function team.TotalPoints(teamid)
	local count = 0

	for _, pl in pairs(team.GetPlayers(teamid)) do
		count = count + pl:Frags()
	end

	return count
end

function team.NumAlivePlayers(teamid)
	local count = 0

	for _, pl in pairs(player.GetAll()) do
		if pl:Alive() and pl:Team() == teamid then count = count + 1 end
	end

	return count
end

function team.NumDiedThisRoundPlayers(teamid)
	local count = 0

	for _, pl in pairs(team.GetPlayers(teamid)) do
		if pl:GetDiedThisRound() then count = count + 1 end
	end

	return count
end

function team.NumDidntDieThisRoundPlayers(teamid)
	local count = 0

	for _, pl in pairs(team.GetPlayers(teamid)) do
		if not pl:GetDiedThisRound() then count = count + 1 end
	end

	return count
end

if not CLIENT then return end

local colFriend = Color(30, 255, 30)
local colEnemy = Color(255, 0, 0)
function team.GetLocalColor(teamid)
	if not MySelf:IsValid() or MySelf:Team() == TEAM_SPECTATOR then
		return team.GetColor(teamid) or color_white
	else
		return teamid == MySelf:Team() and colFriend or colEnemy
	end

	return color_white
end
