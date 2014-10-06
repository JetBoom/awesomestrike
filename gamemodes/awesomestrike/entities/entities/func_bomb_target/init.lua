ENT.Type = "brush"

function ENT:Initialize()
	if self.On == nil then
		self.On = true
	end

	--timer.SimpleEx(0, self.CreateCaptureZone, self)
end

function ENT:CreateCaptureZone()
	--[[local ent = ents.Create("point_capturezone")
	if ent:IsValid() then
		local aa, bb = self:WorldSpaceAABB()
		ent:SetPos(Vector((aa.x + bb.x) / 2, (aa.y + bb.y) / 2, aa.z))
		ent:Spawn()

		ent.m_BombTarget = self
		self.m_CaptureZone = ent

		ent:InitializeCaptureZone(math.min(self:BoundingRadius() / 2, 128))
	end]]
end

function ENT:Think()
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "bombexplode" then
		self:AddOnOutput(key, value)
	end
end

function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	if name == "enable" then
		self.On = true

		return true
	elseif name == "disable" then
		self.On = false
		for _, pl in pairs(player.GetAll()) do
			if pl.CanPlantBomb == self then
				pl.CanPlantBomb = nil
				pl:SendLua("MySelf.CanPlantBomb=nil")
			end
		end

		return true
	elseif name == "toggle" then
		if self.On then
			self:AcceptInput("disable", activator, caller, arg)
		else
			self:AcceptInput("enable", activator, caller, arg)
		end

		return true
	elseif name == "bombexplode" then
		for _, ent in pairs(ents.FindByClass("planted_bomb")) do
			ent:Explode()
		end

		return true
	end
end

function ENT:FireOff(intab, activator, caller)
	for key, tab in pairs(intab) do
		for __, subent in pairs(ents.FindByName(tab.entityname)) do
			if tab.delay == 0 then
				subent:Input(tab.input, activator, caller, tab.args)
			else
				timer.Simple(tab.delay, function() if subent:IsValid() then subent:Input(tab.input, activator, caller, tab.args) end end)
			end
		end
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		ent.CanPlantBomb = self
		ent:SendLua("MySelf.CanPlantBomb="..self:EntIndex())

		if ent:Team() == TEAM_T and #ents.FindByClass("planted_bomb") == 0 then
			ent:Give("weapon_as_bomb")
		end
	end
end

function ENT:EndTouch(ent)
	if ent.CanPlantBomb == self then
		ent.CanPlantBomb = nil
		ent:SendLua("MySelf.CanPlantBomb=nil")

		if ent:Team() == TEAM_T then
			ent:StripWeapon("weapon_as_bomb")
		end
	end
end

function ENT:Touch(ent)
end
