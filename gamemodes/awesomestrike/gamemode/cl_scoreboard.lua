local pScoreBoardLeft
local pScoreBoardRight
local pScoreBoardSpectator

local function SortByUserID(a, b)
	local afrags = a:Frags()
	local bfrags = b:Frags()
	if afrags == bfrags then
		return a:Deaths() < b:Deaths()
	end
	return bfrags < afrags
end

local Scroll = 0

local function profileopen(self, mc)
	if mc == MOUSE_LEFT then
		local player = self.Player
		if player:IsValid() then
			NDB.GeneralPlayerMenu(player, true)
		end
	end
end

local colbox = Color(40, 40, 40, 255)
local function emptypaint(self)
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), colbox)
	return true
end

function GM:ScoreboardRefresh(pScoreBoard)
	for _, element in pairs(pScoreBoard.Elements) do
		element:Remove()
	end
	pScoreBoard.Elements = {}

	local list = vgui.Create("DPanelList", pScoreBoard)
	local panw = w * 0.25 - 8
	list:SetSize(panw, pScoreBoard:GetTall() - 72)
	list:SetPos(4, 64)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSpacing(2)
	timer.SimpleEx(0, list.VBar.SetScroll, list.VBar, Scroll)
	pScoreBoard.PanelList = list
	table.insert(pScoreBoard.Elements, list)

	local Label = vgui.Create("DLabel", pScoreBoard)
	Label:SetText("Score")
	Label:SetTextColor(color_white)
	Label:SetFont("DefaultFontSmall")
	surface.SetFont("DefaultFontSmall")
	local tw, th = surface.GetTextSize("Score")
	Label:SetPos(panw * 0.6 - tw * 0.5 + 8, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(pScoreBoard.Elements, Label)

	local Label = vgui.Create("DLabel", pScoreBoard)
	Label:SetText("Deaths")
	Label:SetTextColor(color_white)
	Label:SetFont("DefaultFontSmall")
	surface.SetFont("DefaultFontSmall")
	local tw, th = surface.GetTextSize("Deaths")
	Label:SetPos(panw * 0.75 - tw * 0.5 + 8, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(pScoreBoard.Elements, Label)

	local Label = vgui.Create("DLabel", pScoreBoard)
	Label:SetText("Ping")
	Label:SetTextColor(color_white)
	Label:SetFont("DefaultFontSmall")
	surface.SetFont("DefaultFontSmall")
	local tw, th = surface.GetTextSize("Ping")
	Label:SetPos(panw * 0.9 + 8 - tw * 0.5, 58 - th)
	Label:SetMouseInputEnabled(false)
	Label:SetKeyboardInputEnabled(false)
	Label:SetSize(tw, th)
	table.insert(pScoreBoard.Elements, Label)

	local allplayers
	if pScoreBoard == pScoreBoardLeft then
		allplayers = team.GetPlayers(TEAM_T)
	elseif pScoreBoard == pScoreBoardRight then
		allplayers = team.GetPlayers(TEAM_CT)
	else
		allplayers = team.GetPlayers(TEAM_SPECTATOR)
	end
	table.sort(allplayers, SortByUserID)
	for i, pl in ipairs(allplayers) do
		local Panel = vgui.Create("Panel", list)
		Panel:SetSize(panw, 40)
		Panel:SetMouseInputEnabled(true)
		Panel.Player = pl
		Panel.Paint = emtptypaint
		Panel.OnMousePressed = profileopen

		if pl:IsValid() then
			local avatar = vgui.Create("AvatarImage", Panel)
			avatar:SetPos(4, 4)
			avatar:SetSize(32, 32)
			avatar:SetPlayer(pl)
		end

		local Label = vgui.Create("DLabel", Panel)
		local txt = pl:Name()
		if not pl:Alive() and pl:Team() ~= TEAM_SPECTATOR then
			txt = "*DEAD* "..txt
			Label:SetTextColor(team.GetColor(TEAM_SPECTATOR))
		else
			Label:SetTextColor(team.GetColor(pl:Team()))
		end
		Label:SetText(txt)
		Label:SetFont("DefaultFontBold")
		surface.SetFont("DefaultFontBold")
		local tw, th = surface.GetTextSize(txt)
		Label:SetPos(48, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)
		Label:SetSize(tw, th)

		local txt = pl:Frags()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("DefaultFontSmall")
		surface.SetFont("DefaultFontSmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.6 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		local txt = pl:Deaths()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("DefaultFontSmall")
		surface.SetFont("DefaultFontSmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.75 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		local txt = pl:Ping()
		local Label = vgui.Create("DLabel", Panel)
		Label:SetText(txt)
		Label:SetTextColor(color_white)
		Label:SetFont("DefaultFontSmall")
		surface.SetFont("DefaultFontSmall")
		local tw, th = surface.GetTextSize(txt)
		Label:SetSize(tw, th)
		Label:SetPos(panw * 0.9 - tw * 0.5, 20 - th * 0.5)
		Label:SetMouseInputEnabled(false)
		Label:SetKeyboardInputEnabled(false)

		list:AddItem(Panel)
	end
end

function GM:CreateScoreboard()
	if pScoreBoardLeft then
		pScoreBoardLeft:Remove()
		pScoreBoardLeft = nil
	end

	pScoreBoardLeft = vgui.Create("DFrame")
	pScoreBoardLeft:SetSize(w * 0.25, h * 0.7)
	pScoreBoardLeft:SetPos(8, 64)
	pScoreBoardLeft:SetVisible(true)
	pScoreBoardLeft:SetTitle(team.GetName(TEAM_T))
	pScoreBoardLeft.btnClose:SetVisible(false)
	pScoreBoardLeft.NextRefresh = CurTime() + 3
	pScoreBoardLeft.Elements = {}
	local oldthink = pScoreBoardLeft.Think
	pScoreBoardLeft.Think = function(p)
		oldthink(p)

		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = pScoreBoardLeft.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	if pScoreBoardRight then
		pScoreBoardRight:Remove()
		pScoreBoardRight = nil
	end

	pScoreBoardRight = vgui.Create("DFrame")
	pScoreBoardRight:SetSize(w * 0.25, h * 0.7)
	pScoreBoardRight:SetPos(w * 0.75 - 8, 64)
	pScoreBoardRight:SetVisible(true)
	pScoreBoardRight:SetTitle(team.GetName(TEAM_CT))
	pScoreBoardRight.btnClose:SetVisible(false)
	pScoreBoardRight.NextRefresh = CurTime() + 3
	pScoreBoardRight.Elements = {}
	local oldthink = pScoreBoardRight.Think
	pScoreBoardRight.Think = function(p)
		oldthink(p)

		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = pScoreBoardRight.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	if pScoreBoardSpectator then
		pScoreBoardSpectator:Remove()
		pScoreBoardSpectator = nil
	end

	pScoreBoardSpectator = vgui.Create("DFrame")
	pScoreBoardSpectator:SetSize(w * 0.25, h * 0.3 - 64)
	pScoreBoardSpectator:SetPos(8, h * 0.7 + 64)
	pScoreBoardSpectator:SetVisible(true)
	pScoreBoardSpectator:SetTitle(team.GetName(TEAM_SPECTATOR))
	pScoreBoardSpectator.btnClose:SetVisible(false)
	pScoreBoardSpectator.NextRefresh = CurTime() + 3
	pScoreBoardSpectator.Elements = {}
	local oldthink = pScoreBoardSpectator.Think
	pScoreBoardSpectator.Think = function(p)
		oldthink(p)

		if p.NextRefresh < CurTime() then
			p.NextRefresh = CurTime() + 3
			Scroll = pScoreBoardSpectator.PanelList.VBar:GetScroll()
			GAMEMODE:ScoreboardRefresh(p)
		end
	end

	self:ScoreboardRefresh(pScoreBoardLeft)
	self:ScoreboardRefresh(pScoreBoardRight)
	self:ScoreboardRefresh(pScoreBoardSpectator)
end

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker(true)

	if not pScoreBoardLeft then
		self:CreateScoreboard()
	end

	pScoreBoardLeft:SetVisible(true)
	pScoreBoardRight:SetVisible(true)
	pScoreBoardSpectator:SetVisible(true)
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false

	if not MOUSE_VIEW then
		gui.EnableScreenClicker(false)
	end

	pScoreBoardLeft:Remove()
	pScoreBoardLeft = nil
	pScoreBoardRight:Remove()
	pScoreBoardRight = nil
	pScoreBoardSpectator:Remove()
	pScoreBoardSpectator = nil
end

function GM:HUDDrawScoreBoard()
end
