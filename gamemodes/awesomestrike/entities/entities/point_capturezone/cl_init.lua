include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetRenderBounds(Vector(-512, -512, -512), Vector(512, 512, 512))

	self.AmbientSound = CreateSound(self, "ambient/machines/combine_shield_loop3.wav")
end

function ENT:Think()
	self.AmbientSound:PlayEx(0.8, 100 + CurTime() % 0.1)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/glow04_noz")
local FriendlyColor = Color(30, 255, 30)
local EnemyColor = Color(255, 0, 0)
local NeutralColor = Color(255, 177, 0)
local col = Color(255, 177, 0)
function ENT:DrawTranslucent()
	local myteam = self:GetTeam()
	if not MySelf:IsValid() or MySelf:Team() == TEAM_SPECTATOR then
		ApproachColor(col, team.GetColor(myteam) or NeutralColor, 90)
	else
		ApproachColor(col, myteam == 0 and NeutralColor or myteam == MySelf:Team() and FriendlyColor or EnemyColor, 90)
	end

	local mypos = self:GetPos() + Vector(0, 0, 8)

	self:SetColor(Color(col.r, col.g, col.b, 255))
	self:SetRenderAngles(Angle(0, CurTime() * 180, 90))
	local offset = Vector(0, 0, math.sin(CurTime() * 2) * 16 + 72)
	local eyepos = EyePos()
	cam.Start3D(eyepos - offset, EyeAngles())
		render.SetMaterial(matGlow)
		render.DrawSprite(mypos, 32, 32, col)
		self:DrawModel()
	cam.End3D()

	local t, ct = self:GetCapturingPlayerCounts()
	local ang = (eyepos - mypos):Angle()
	ang.pitch = 0
	ang.roll = 90
	ang.yaw = ang.yaw + 90
	cam.Start3D2D(mypos + offset + Vector(0, 0, 32), ang, 0.1)
		local capturing = self:GetCapturingTeam()
		if capturing > 0 and MySelf:IsValid() then
			local col = team.GetLocalColor(capturing)
			if MySelf:Team() == capturing then
				local tim = CurTime() % 1
				draw.SimpleText((tim < 0.33 and "\\" or tim < 0.66 and "[" or "/").."CAPTURING"..(tim < 0.33 and "/" or tim < 0.66 and "]" or "\\"), "ass72_shadow", 0, 0, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER)
			elseif MySelf:Team() ~= TEAM_SPECTATOR and CurTime() % 0.5 <= 0.25 then
				draw.SimpleText("WARNING!", "ass72_shadow", 0, 0, COLOR_RED, TEXT_ALIGN_CENTER)
			else
				local tim = CurTime() % 1
				draw.SimpleText((tim < 0.33 and "\\" or tim < 0.66 and "[" or "/").."CAPTURING"..(tim < 0.33 and "/" or tim < 0.66 and "]" or "\\"), "ass72_shadow", 0, 0, col, TEXT_ALIGN_CENTER)
			end

			local wid, hei = 512, 32
			local x, y = wid * -0.5, 80
			surface.SetDrawColor(0, 0, 0, 190)
			surface.DrawRect(x, y, wid, hei)
			surface.SetDrawColor(col.r, col.g, col.b, 190)
			surface.DrawOutlinedRect(x, y, wid, hei)
			surface.DrawRect(x + 2, y + 2, (wid - 4) * math.Clamp((CurTime() - self:GetCaptureStart()) / GAMEMODE.CaptureTime, 0, 1), hei - 4)
		elseif self:GetTeam() > 0 then
			draw.SimpleText("CAPTURE ZONE", "ass72_shadow", 0, 0, team.GetLocalColor(self:GetTeam()), TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()

	local seed = CurTime() * 45
	local ang = Angle(0, seed, 0)
	local up = ang:Up()

	local lastdistance = self:BoundingRadius()

	render.SetMaterial(matGlow)
	for i=0, 345, 15 do
		local dir = ang:Forward()
		local ringpos = mypos + lastdistance * dir

		render.DrawQuadEasy(ringpos, dir, 24, 200, col)
		render.DrawQuadEasy(ringpos, dir * -1, 24, 200, col)
		render.DrawSprite(ringpos, 32, 32, col)

		ang:RotateAroundAxis(up, 15)
	end
end

function ENT:GetCapturingPlayerCounts()
	return self:GetTCount(), self:GetCTCount()
end
