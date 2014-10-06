include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))

	GAMEMODE.IsCTF = true
end

function ENT:Think()
	self:AlignToCarrier()

	self:NextThink(CurTime())
	return true
end

local matWall = Material("VGUI/white")
local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	self:AlignToCarrier()

	local pos = self:GetPos()

	local colFlag = self:GetColor()

	self:DrawModel()

	local rsin = math.sin(CurTime() * 4) * 16
	local rcon = math.cos(CurTime() * 4) * 16
	local size =  math.sin(CurTime() * 5) * 60 + 90
	local minisize = size * 0.5

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size, size, drawColor)
	render.DrawSprite(pos + Vector(rsin, rcon, 0), minisize, minisize, colFlag)
	render.DrawSprite(pos + Vector(0, rcon, rsin), minisize, minisize, colFlag)
	render.DrawSprite(pos + Vector(rcon, 0, rsin), minisize, minisize, colFlag)
end
