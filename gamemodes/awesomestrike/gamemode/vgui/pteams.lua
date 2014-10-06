local Window

local function SubmitTeam(btn)
	RunConsoleCommand("changeteam", btn.TeamID)
	Window:Close()
end

function GM:ShowTeam()
	if Window and Window:Valid() then
		Window:Close()
		Window = nil
	end

	Window = vgui.Create("DFrame")
	Window:SetWide(350)
	Window:SetTitle("SELECT TEAM")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:SetKeyboardInputEnabled(false)
	Window:SetDeleteOnClose(true)

	local buttonwide = Window:GetWide() - 32

	local y = 32

	local button = CSButton(Window, "COUNTER-TERRORIST FORCES", function(btn) RunConsoleCommand("changeteam", TEAM_CT) Window:Close() end)
	button:SetWide(buttonwide)
	button:SetPos(0, y)
	button:CenterHorizontal()
	y = y + button:GetTall() + 16

	local button = CSButton(Window, "TERRORIST FORCES", function(btn) RunConsoleCommand("changeteam", TEAM_T) Window:Close() end)
	button:SetWide(buttonwide)
	button:SetPos(0, y)
	button:CenterHorizontal()
	y = y + button:GetTall() + 16

	local button = CSButton(Window, "AUTO-SELECT", function(btn)
		local numt = team.NumPlayers(TEAM_T)
		local numct = team.NumPlayers(TEAM_CT)
		if numt == numct then
			if math.random(1, 2) == 1 then
				RunConsoleCommand("changeteam", TEAM_CT)
			else
				RunConsoleCommand("changeteam", TEAM_T)
			end
		elseif numt < numct then
			RunConsoleCommand("changeteam", TEAM_T)
		else
			RunConsoleCommand("changeteam", TEAM_CT)
		end

		Window:Close()
	end)
	button:SetWide(buttonwide)
	button:SetPos(0, y)
	button:CenterHorizontal()
	y = y + button:GetTall() + 32

	local button = CSButton(Window, "SPECTATE", function(btn) RunConsoleCommand("changeteam", TEAM_SPECTATOR) Window:Remove() end)
	button:SetWide(buttonwide)
	button:SetPos(0, y)
	button:CenterHorizontal()
	y = y + button:GetTall() + 64

	local button = CSButton(Window, "SELECT CHARACTER", function(btn) GAMEMODE:ShowCharacterSelect() end)
	button:SetWide(buttonwide)
	button:SetPos(0, y)
	button:CenterHorizontal()
	y = y + button:GetTall() + 16

	Window:SetTall(y)

	Window:Center()
	Window:MakePopup()

	DrawStylishBackground(Window)
end
