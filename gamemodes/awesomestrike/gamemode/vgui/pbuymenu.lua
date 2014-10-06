local pWeaponBar
local pWeaponSelection

local function CloseButtonDoClick(self)
	self:GetParent():Remove()
end

local color_black_alpha120 = Color(0, 0, 0, 120)
local function pWeaponBarPaint(self)
	draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), color_black_alpha120)

	return true
end

local function PreviewDoClick(self)
	if self.Slot == -1 then
		RunConsoleCommand("awesomestrike_skill", self.BuyableID)
	else
		RunConsoleCommand("awesomestrike_weapon"..self.Slot, self.BuyableID)
	end
	pWeaponSelection:Remove()
end

local function PreviewThink(self)
	if not self.Hovered or pWeaponSelection.BuyableID == self.BuyableID then return end
	pWeaponSelection.BuyableID = self.BuyableID

	if pWeaponSelection._Preview and pWeaponSelection._Preview then
		pWeaponSelection._Preview:Remove()
	end

	local isskill = self.Slot == -1
	local buyable
	if isskill then
		buyable = SKILLS[self.BuyableID]
	else
		buyable = GAMEMODE:GetBuyable(MySelf, self.BuyableID)
	end

	if buyable then
		local window = vgui.Create(isskill and "DSkillStats" or "DWeaponStats", pWeaponSelection)
		window:SetBuyable(buyable)
		window:SetSize(pWeaponSelection:GetWide() - 32, pWeaponSelection:GetTall() * 0.5 - 32)
		window:SetPos(16, 24)
		pWeaponSelection._Preview = window
	end
end

function GM:ShowWeaponSelection(slot)
	if pWeaponSelection and pWeaponSelection:Valid() then
		pWeaponSelection:Remove()
	end

	slot = slot or 1

	local window = vgui.Create("DFrame")
	if slot == -1 then
		window:SetTitle("CHOOSE YOUR SKILL")
	else
		window:SetTitle("CHOOSE A WEAPON FOR SLOT "..slot)
	end
	window:SetDraggable(false)
	window:SetDeleteOnClose(true)
	window:SetSize(500, ScrH() * 0.75 - 192)
	pWeaponSelection = window

	local list = vgui.Create("DPanelList", window)
	list:SetSize(window:GetWide() - 16, window:GetTall() * 0.5 - 16)
	list:SetPos(8, window:GetTall() * 0.5 + 8)
	list:SetPadding(8)
	list:SetSpacing(2)
	list:EnableVerticalScrollbar()

	if slot == -1 then
		for skillid, skilltab in ipairs(SKILLS) do
			if skillid == SKILL_NONE then continue end

			local text = string.upper(skilltab.Name)
			if GetConVarNumber("awesomestrike_skill") == skillid then
				text = ">> "..text.." <<"
			end
			local button = EasyButton(list, text, 0, 4)
			button.Slot = -1
			button.BuyableID = skillid
			button.DoClick = PreviewDoClick
			button.Think = PreviewThink

			list:AddItem(button)
		end
	else
		for weptype, weptypename in ipairs(GAMEMODE.WeaponTypes) do
			local pan = vgui.Create("DPanel", list)
			pan:SetTall(32)
			list:AddItem(pan)
			local lab = EasyLabel(pan, weptypename, "ass24_shadow", COLOR_TEXTYELLOW)
			lab:CenterVertical()
			lab:AlignLeft(32)

			for i=1, #GAMEMODE.Buyables do
				local weptab = GAMEMODE:GetBuyable(LocalPlayer(), i)
				if not weptab or weptab.Type ~= weptype then continue end

				local text = string.upper(weptab.Name)
				if GetConVarNumber("awesomestrike_weapon1") == i or GetConVarNumber("awesomestrike_weapon2") == i or GetConVarNumber("awesomestrike_weapon3") == i then
					text = ">> "..text.." <<"
				end

				local button = EasyButton(list, text, 0, 4)
				button.Slot = slot
				button.BuyableID = i
				button.Buyable = weptab
				button.DoClick = PreviewDoClick
				button.Think = PreviewThink

				list:AddItem(button)
			end
		end
	end

	window:CenterHorizontal()
	window:AlignTop(ScrH() * 0.1 + 192)
	window:MakePopup()

	DrawStylishBackground(window)
end

function GM:ShowSpare1()
	if pWeaponBar and pWeaponBar:Valid() then
		pWeaponBar:Remove()
	end

	pWeaponBar = vgui.Create("DPanel")
	pWeaponBar.Paint = pWeaponBarPaint
	pWeaponBar:SetTall(184)

	local x = 16
	for i=1, 3 do
		local icon = vgui.Create("DWeaponIcon", pWeaponBar)
		icon:SetSize(128, 128)
		icon:SetPos(x, 16)
		icon:SetSlot(i)

		x = x + icon:GetWide() + 16
	end

	local icon = vgui.Create("DSkillIcon", pWeaponBar)
	icon:SetSize(128, 128)
	icon:SetPos(x, 16)
	x = x + icon:GetWide() + 16

	pWeaponBar:SetWide(x)

	local closebutton = EasyButton(pWeaponBar, "Close", 0, 8)
	closebutton:SetWide(pWeaponBar:GetWide() / 2)
	closebutton:CenterHorizontal()
	closebutton:AlignBottom(8)
	closebutton.DoClick = CloseButtonDoClick

	pWeaponBar:CenterHorizontal()
	pWeaponBar:AlignTop(ScrH() * 0.1)
	pWeaponBar:MakePopup()

	DrawStylishBackground(pWeaponBar)
end
