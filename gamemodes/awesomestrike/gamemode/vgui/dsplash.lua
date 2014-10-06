local SplashStart
local SplashEnd

local PANEL = {}

PANEL.SplashTime = 3

function PANEL:Init()
	if SplashStart then return end

	SplashStart = CurTime()
	SplashEnd = CurTime() + self.SplashTime
end

function PANEL:Think()
end

function PANEL:GetDelta()
	return math.max(0, SplashEnd - CurTime()) / self.SplashTime
end

function PANEL:PerformLayout()
end

local texGear1 = surface.GetTextureID("awesomestrike/gear1")
function PANEL:Paint()
	local fadein = 1 - self:GetDelta()
	local wid, hei = self:GetSize()

	local rot = RealTime() * 90
	surface.SetTexture(texGear1)
	surface.SetDrawColor(0, 0, 0, 255 * fadein)
	surface.DrawTexturedRectRotated(hei / 2, hei / 2, hei, hei, rot)
	surface.SetDrawColor(255, 177, 0, 255 * fadein)
	surface.DrawTexturedRectRotated(hei / 2, hei / 2, hei * 0.9, hei * 0.9, rot)

	return true
end

vgui.Register("DSplash", PANEL, "Panel")
