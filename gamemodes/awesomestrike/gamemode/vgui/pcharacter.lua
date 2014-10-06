local Window

local function SubmitModel(btn)
	RunConsoleCommand("cl_playermodel", btn.ModelName)
	Window:Close()
	GAMEMODE:ShowTeam()
end

local function SkinSelectThink(btn)
	if btn.Hovered and Window.CurrentButton ~= btn then
		Window.CurrentButton = btn
		if Window.Preview then
			Window.Preview:SetModel(btn.Model)
			Window.Preview:AutoCam(8)
		else
			local preview = vgui.Create("DModelPanel2", Window)
			preview:SetSize(400, 400)
			preview:AlignRight(16)
			preview:AlignTop(48)
			preview:SetModel(btn.Model)
			preview:SetAnimated(true)
			preview:SetAnimSpeed(1)
			preview:SetRotateRate(45)
			preview:AutoCam(8)
			Window.Preview = preview
		end
	end
end

function GM:ShowCharacterSelect()
	if Window and Window:Valid() then
		Window:Close()
		Window = nil
	end

	local pw = 800
	local ph = 600

	Window = vgui.Create("DFrame")
	Window:SetSize(pw, ph)
	Window:SetTitle("SELECT CHARACTER")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:SetKeyboardInputEnabled(false)
	Window:SetDeleteOnClose(true)

	local pList = vgui.Create("DPanelList", Window)
	pList:SetPos(48, 32)
	pList:SetSize(300, ph - 64)
	pList:SetSpacing(8)
	pList:EnableVerticalScrollbar()

	for name, mdl in pairs(player_manager.AllValidModels()) do
		local button = CSButton(panel, string.upper(name), SubmitModel, nil, SkinSelectThink)
		button.Model = mdl
		button.ModelName = name

		local oldwide = button:GetWide()
		pList:AddItem(button)
		button:SetWide(oldwide)
	end

	Window:Center()
	Window:MakePopup()

	DrawStylishBackground(Window)
end
