local PANEL = {}

function PANEL:Paint()
	return true
end

function PANEL:Init()
	local mdlpanel = vgui.Create("DModelPanel2", self)
	mdlpanel:SetRotateRate(45)
	mdlpanel:SetMouseInputEnabled(false)
	mdlpanel:SetVisible(false)
	self.m_ModelPanel = mdlpanel

	self.m_NameLabel = EasyLabel(self, " ", "ass24", COLOR_TEXTYELLOW)
	self.m_DescLabel = EasyLabel(self, " ", "ass14", COLOR_TEXTYELLOW)
	self.m_DescLabel:SetContentAlignment(7)
	self.m_DescLabel:SetWrap(true)

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	if self.m_ModelPanel then
		local size = math.min(self:GetWide(), self:GetTall()) / 2
		self.m_ModelPanel:SetSize(size, size)
		self.m_ModelPanel:AlignRight()
		self.m_ModelPanel:CenterVertical()
		self.m_ModelPanel:AutoCam()
	end

	local y = 0
	if self.m_NameLabel then
		y = y + self.m_NameLabel:GetTall() + 16
	end

	if self.m_DescLabel then
		self.m_DescLabel:SetPos(0, y)
		self.m_DescLabel:SetSize(self:GetWide() / 2, self:GetTall())
	end
end

function PANEL:GetBuyableModel()
	local buyable = self:GetBuyable()
	if buyable.Model then return buyable.Model end

	if buyable.SWEP then
		local stored = weapons.GetStored(buyable.SWEP)
		if stored then
			return stored.WorldModel
		end
	end
end

function PANEL:RefreshBuyable()
	local buyable = self.m_Buyable
	if buyable then
		if buyable.Icon then
			self.m_ModelPanel:SetVisible(false)
		else
			local mdl = self:GetBuyableModel()
			if mdl then
				self.m_ModelPanel:SetModel(mdl)
				self.m_ModelPanel:SetVisible(true)
			else
				self.m_ModelPanel:SetVisible(false)
			end
		end

		if buyable.Name then
			self.m_NameLabel:SetText(buyable.Name)
			self.m_NameLabel:SizeToContents()
			self.m_NameLabel:SetVisible(true)
		else
			self.m_NameLabel:SetVisible(false)
		end

		if buyable.Description then
			self.m_DescLabel:SetText(buyable.Description)
			self.m_DescLabel:SetVisible(true)
		else
			self.m_DescLabel:SetVisible(false)
		end
	end

	self:InvalidateLayout()
end

function PANEL:SetBuyable(buyable)
	self.m_Buyable = buyable
	self:RefreshBuyable()
end

function PANEL:GetBuyable()
	return self.m_Buyable
end

vgui.Register("DWeaponStats", PANEL, "DPanel")
