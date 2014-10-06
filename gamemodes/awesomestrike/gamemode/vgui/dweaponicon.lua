local PANEL = {}

PANEL.m_Slot = 0

local CachedIcons = {}
local function CachedIcon(name)
	if CachedIcons then return CachedIcons[name] end

	CachedIcons[name] = surface.GetTextureID(name)

	return CachedIcons[name]
end

function PANEL:Paint()
	local wid, hei = self:GetSize()

	if self.Hovered or self.Depressed then
		surface.SetDrawColor(100, 60, 15, 120)
	else
		surface.SetDrawColor(0, 0, 0, 120)
	end
	surface.DrawRect(0, 0, wid, hei)
	surface.SetDrawColor(255, 177, 0, 255)
	surface.DrawOutlinedRect(0, 0, wid, hei)
	surface.DrawRect(0, 0, 18, 18)
	draw.SimpleText(self:GetSlotText(), "ass14", 9, 9, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local displayname = self:GetDisplayName()
	if displayname then
		surface.SetDrawColor(255, 177, 0, 255)
		surface.DrawRect(0, hei - 20, wid, 20)
		draw.SimpleText(displayname, "ass14", wid / 2, hei - 10, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local icon = self:GetDisplayIcon()
	if icon then
		local size = math.min(wid - 32, hei - 42)
		surface.SetTexture(CachedIcon(icon))
		surface.SetDrawColor(255, 177, 0, 255)
		surface.DrawTexturedRect((wid - size) * 0.5, (hei - size) * 0.5, size, size)
	end

	return true
end

function PANEL:Think()
	local model = self:GetDisplayModel()
	if self._CurrentModel ~= model then
		self._CurrentModel = model

		if self.m_ModelPanel and self.m_ModelPanel:Valid() then
			self.m_ModelPanel:Remove()
		end

		if model then
			self.m_ModelPanel = vgui.Create("DModelPanel2", self)
			self.m_ModelPanel:SetModel(model)
			self.m_ModelPanel:SetRotateRate(180)
			self.m_ModelPanel:SetMouseInputEnabled(false)
		end

		self:InvalidateLayout()
	end

	if self.m_ModelPanel and self.m_ModelPanel:Valid() then
		if self.Hovered or self.Depressed then
			self.m_ModelPanel:SetRotateRate(180)
		else
			self.m_ModelPanel:SetRotateRate(90)
		end
	end
end

function PANEL:GetDisplayModel()
	local buyable = self:GetBuyable()
	if buyable and not buyable.Icon and buyable.SWEP then
		local stored = weapons.GetStored(buyable.SWEP)
		if stored then
			return stored.WorldModel
		end
	end
end

function PANEL:GetDisplayIcon()
	local buyable = self:GetBuyable()
	if buyable then
		return buyable.Icon
	end
end

function PANEL:PerformLayout()
	if self.m_ModelPanel then
		local size = math.min(self:GetWide() - 32, self:GetTall() - 42)
		self.m_ModelPanel:SetSize(size, size)
		self.m_ModelPanel:Center()
		self.m_ModelPanel:AutoCam()
	end
end

function PANEL:GetDisplayName()
	local buyable = self:GetBuyable()
	if buyable then
		return buyable.ShortName or buyable.Name
	end
end

function PANEL:DoClick()
	GAMEMODE:ShowWeaponSelection(self:GetSlot())
end

function PANEL:GetSlotText()
	return tostring(self:GetSlot())
end

function PANEL:GetBuyable()
	return GAMEMODE:GetBuyable(MySelf, GetConVarNumber("awesomestrike_weapon"..self:GetSlot()))
end

function PANEL:SetSlot(slot)
	self.m_Slot = slot
end

function PANEL:GetSlot()
	return self.m_Slot
end

vgui.Register("DWeaponIcon", PANEL, "DButton")
