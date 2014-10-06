local SKIN = {}

SKIN.bg_color = Color(0, 0, 0, 220)
SKIN.bg_color_sleep = Color(0, 0, 0, 255)
SKIN.bg_color_dark = Color(0, 0, 0, 255)
SKIN.bg_color_bright = Color(60, 60, 60, 220)

SKIN.control_color = Color(200, 100, 4, 180)
SKIN.control_color_highlight = Color(220, 140, 6, 180)
SKIN.control_color_active = Color(240, 200, 20, 180)
SKIN.control_color_bright = Color(235, 235, 100, 180)
SKIN.control_color_dark = Color(100, 100, 100, 180)

SKIN.panel_transback = Color(0, 0, 0, 220)

SKIN.bg_alt1 = Color(0, 0, 0, 220)
SKIN.bg_alt2 = Color(45, 40, 25, 220)

SKIN.listview_hover = Color(70, 70, 70, 255)
SKIN.listview_selected = Color(100, 170, 220, 255)

SKIN.text_bright = Color(255, 255, 255, 255)
SKIN.text_normal = Color(230, 230, 60, 255)
SKIN.text_dark = Color(200, 200, 20, 255)
SKIN.text_highlight = Color(255, 255, 75, 255)

SKIN.panel_transback = Color(255, 255, 255, 50)
SKIN.tooltip = Color(255, 200, 175, 220)

--SKIN.colButtonText = Color(255, 177, 0, 255)
--SKIN.colButtonTextDisabled = Color(95, 56, 0, 255)
SKIN.colButtonText = Color(0, 0, 0, 255)
SKIN.colButtonTextDisabled = Color(0, 0, 0, 190)
SKIN.colButtonBorder = Color(95, 56, 0, 255)
SKIN.colButtonBorderHighlight = Color(255, 177, 0, 255)
SKIN.colButtonBorderShadow = Color(0, 0, 0, 0)
SKIN.colButtonBG = Color(255, 177, 0, 255)
SKIN.colButtonBGShadow = Color(200, 120, 0, 255)
SKIN.colButtonBGHighlight = Color(255, 220, 30, 255)
SKIN.colButtonBGHighlightShadow = Color(220, 180, 10, 255)

SKIN.fontFrame = "DefaultFontBold"

function ApproachColor(col1, col2, rate)
	rate = rate or FrameTime() * 510

	col1.r = math.Approach(col1.r, col2.r, rate)
	col1.g = math.Approach(col1.g, col2.g, rate)
	col1.b = math.Approach(col1.b, col2.b, rate)
	col1.a = math.Approach(col1.a, col2.a, rate)
end

function SKIN:ApproachColor(col1, col2, rate)
	ApproachColor(col1, col2, rate)
end

function SKIN:PaintVScrollBar(panel)
end

function SKIN:PaintPanelList(panel)
end

function SKIN:LayoutFrame(panel)
	local lblTitle = panel.lblTitle
	local strfont = panel.fontFrame or self.fontFrame
	lblTitle:SetFont(strfont)
	lblTitle:SetTextColor(COLOR_TEXTYELLOW)
	lblTitle:SetPos(8, 8)
	surface.SetFont(strfont)
	local txtw, txth = surface.GetTextSize("Test")
	lblTitle:SetSize(panel:GetWide() - 32, txth)
	lblTitle:SetMouseInputEnabled(false)
	lblTitle:SetKeyboardInputEnabled(false)

	panel.btnClose:SetPos(panel:GetWide() - 22, 4)
	panel.btnClose:SetSize(18, 18)
end

local texGear = surface.GetTextureID("awesomestrike/gear1")
function SKIN:PaintButton(panel)
	if panel.m_bBackground then
		local pressed = panel.Hovered or panel.Depressed
		local pw, ph = panel:GetSize()

		if pressed then
			if not panel._PrevPressed then
				panel._PrevPressed = true
				surface.PlaySound("buttons/lightswitch2.wav")
				if not panel._NoResizes or RealTime() > panel._NoResizes then
					panel._NoResizes = RealTime() + 0.4
					--panel:AlphaTo(100, 0.3)
					--panel:AlphaTo(255, 0.1, 0.3)
				end
			end
		elseif panel._PrevPressed then
			panel._PrevPressed = nil
		end

		--[[panel._SkinColor = panel._SkinColor or table.Copy(COLOR_LINEYELLOW)
		self:ApproachColor(panel._SkinColor, panel:GetDisabled() and color_black or pressed and color_white or COLOR_LINEYELLOW)

		surface.SetDrawColor(panel._SkinColor)
		surface.DrawOutlinedRect(0, 0, pw, ph)
		if pressed then
			local time = CurTime() * 5
			local baseindent = math.min(panel:GetWide(), panel:GetTall()) * 0.2
			for i = 0, 1, 0.333 do
				local indent = time % 1 * i * baseindent
				surface.DrawOutlinedRect(indent, indent, pw - indent * 2, ph - indent * 2)
			end
		end]]

		panel._SkinColor = panel._SkinColor or table.Copy(self.colButtonBGShadow)
		self:ApproachColor(panel._SkinColor, pressed and self.colButtonBGHighlightShadow or self.colButtonBGShadow)

		draw.RoundedBox(8, 0, 0, pw, ph, pressed and self.colButtonBGHighlightShadow or self.colButtonBGShadow)
		draw.RoundedBox(8, 4, 0, pw - 8, ph, pressed and self.colButtonBGHighlight or self.colButtonBG)

		local gs = math.min(pw, ph) - 4
		local rot = pressed and 360 or 180
		surface.SetTexture(texGear)
		surface.SetDrawColor(panel._SkinColor)
		surface.DrawTexturedRectRotated(2 + gs * 0.5, 2 + gs * 0.5, gs, gs, CurTime() * rot)
		surface.DrawTexturedRectRotated(2 + gs * 0.5, 2 + gs * 0.5, gs * 0.45, gs * 0.45, CurTime() * -rot)
		surface.DrawTexturedRectRotated(pw - gs * 0.5 - 2, 2 + gs * 0.5, gs, gs, CurTime() * -rot)
		surface.DrawTexturedRectRotated(pw - gs * 0.5 - 2, 2 + gs * 0.5, gs * 0.45, gs * 0.45, CurTime() * rot)
	end
end

function SKIN:PaintOverButton(panel)
end

function SKIN:DrawGenericBackground(x, y, w, h, color)
	draw.RoundedBox(8, x, y, w, h, color)
end

local color_black_alpha220 = Color(0, 0, 0, 220)
function SKIN:PaintFrame(panel)
	local pw, pt = panel:GetSize()
	draw.RoundedBox(16, 0, 0, pw, pt, color_black_alpha220)

	if panel.m_DrawStylishBackground then
		DrawStylishBackground(panel)
	end
end

function SKIN:DrawButtonBorder(x, y, w, h, depressed)
	if depressed then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x, y, w, h)
	else
		surface.SetDrawColor(220, 220, 20, 255)
		surface.DrawOutlinedRect(x, y, w, h)
	end
end

function SKIN:SchemeButton(panel)
	panel:SetContentAlignment(5)
	panel:SetTextColor(self.colButtonText)
	panel:SetFont("ass14")
end

derma.DefineSkin("awesomestrike", "Derma skin for Awesome Strike: Source", SKIN, "Default")

function GM:ForceDermaSkin()
	return "awesomestrike"
end
