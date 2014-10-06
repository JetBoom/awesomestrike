local meta = FindMetaTable("Player")
if not meta then return end

function meta:SetNextRespawn(time)
	self.m_RespawnTime = time
end

function meta:SetMaxHealthEx(maxhealth)
	self:SetDTInt(2, maxhealth)
end

usermessage.Hook("respawntime", function(um)
	MySelf:SetNextRespawn(um:ReadFloat())
end)

function meta:GetMaxHealthEx()
	return self:GetDTInt(2)
end

function meta:EndState(nocallended)
	if self == MySelf then
		self:SetState(STATE_NONE, nil, nil, nocallended)
	end
end

usermessage.Hook("setenergy", function(um)
	MySelf.Energy = um:ReadFloat()
	MySelf.EnergyRegeneration = um:ReadFloat()
	MySelf.EnergyBase = um:ReadFloat()
end)
function meta:SetEnergy(energy, regeneration)
	self.Energy = energy
	self.EnergyRegeneration = regeneration or self.EnergyRegeneration
	self.EnergyBase = CurTime()
end

function meta:SetCombo(combo)
	self.Combo = combo
	self.ComboEndTime = CurTime() + GAMEMODE.ComboTime
end

usermessage.Hook("setcombo", function(um)
	GAMEMODE.LastHurtOtherTick = CurTime()

	MySelf.Combo = um:ReadShort()
	MySelf.ComboEndTime = um:ReadFloat()
end)

local matWhite = Material("models/debug/debug_white")
function meta:DrawFadeTrail(amount)
	local eyepos = EyePos()
	local eyeangles = EyeAngles()
	local vel = self:GetVelocity()
	self.SkipDrawHooks = true

	render.SetColorModulation(0.02, 0.02, 0.02)
	render.MaterialOverride(matWhite)
	for i=0.2, 1, 0.2 do
		cam.Start3D(eyepos + i * 0.05 * vel, eyeangles)
			render.SetBlend((1.2 - i) * 0.1 * amount)
			self:DrawModel(true)
			render.SetBlend(1)
		cam.End3D()
	end
	render.MaterialOverride()
	render.SetColorModulation(1, 1, 1)

	self.SkipDrawHooks = nil
end

local function CollideCallbackSmall(particle, hitpos, hitnormal)
	particle:SetDieTime(0)
	sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
	util.Decal("Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
end
local ShadowParams = {secondstoarrive = 0.0001, maxangular = 0, maxangulardamp = 0, maxspeed = 32000, maxspeeddamp = 1024, dampfactor = 0.5, angle = Angle(0, 0, 0), teleportdistance = 32}
function meta:Think()
	local emitter = self:ParticleEmitter()
	emitter:SetPos(self:GetPos())

	if self:Alive() and CurTime() >= (self.NextBloodDrip or 0) then
		local health = self:Health()
		if health <= 25 then
			self.NextBloodDrip = CurTime() + health / 12.5 + math.Rand(1, 2)
			local pos = self:LocalToWorld(self:OBBCenter())
			for i=1, math.random(1, 3) do
				local particle = emitter:Add("noxctf/sprite_bloodspray"..math.random(1, 8), pos + VectorRand():GetNormalized() * math.Rand(1, 8))
				particle:SetLighting(true)
				particle:SetVelocity(self:GetVelocity() * math.Rand(0.6, 0.8) + VectorRand():GetNormalized() * math.Rand(2, 8))
				particle:SetDieTime(3)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(math.Rand(1.5, 2.5))
				particle:SetEndSize(1.5)
				particle:SetRoll(math.Rand(-25, 25))
				particle:SetRollDelta(math.Rand(-25, 25))
				particle:SetAirResistance(5)
				particle:SetBounce(0)
				particle:SetGravity(Vector(0, 0, -600))
				particle:SetColor(255, 0, 0)
				particle:SetCollide(true)
				particle:SetCollideCallback(CollideCallbackSmall)
			end
		end
	end

	if self == MySelf then
		local health = self:Health()
		if self.PrevHealth and health < self.PrevHealth then
			GAMEMODE.HurtEffect = math.min(GAMEMODE.HurtEffect + (self.PrevHealth - health) * 0.02, 1.5)
		else
			GAMEMODE.HurtEffect = math.max(0, GAMEMODE.HurtEffect - FrameTime() * 0.65)
		end
		self.PrevHealth = health

		self:ThinkShared()

		self:ForceUnDuck()
	else
		self:CallStateFunction("ThinkOther")
	end
end

function meta:IsFirstPersonEntity()
	return GetViewEntity() == self and not self:ShouldDrawLocalPlayer()
end

function meta:GetTomb()
	for _, ent in pairs(ents.FindByClass("prop_playertomb")) do
		if ent:GetOwner() == self then return ent end
	end

	return NULL
end

local FootParticles = {[TEAM_CT] = "effects/strider_muzzle", [TEAM_T] = "effects/fire_cloud1"}
function meta:CreateFootParticle(pos)
	local particletype = FootParticles[self:Team()] or FootParticles[TEAM_T]
	local emitter = self:ParticleEmitter()
	for i=1, 3 do
		local particle = emitter:Add(particletype, pos + VectorRand():GetNormalized() * math.Rand(1, 5))
		particle:SetDieTime(math.Rand(0.7, 0.9))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		local size = math.Rand(2, 3)
		particle:SetStartSize(size)
		particle:SetEndSize(size)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-5, 5))
	end
end
function meta:CreateFootParticles()
	local boneindex = self:LookupBone("valvebiped.bip01_l_foot")
	if boneindex then
		local pos, ang = self:GetBonePosition(boneindex)
		if pos then
			self:CreateFootParticle(pos)
		end
	end

	local boneindex2 = self:LookupBone("valvebiped.bip01_r_foot")
	if boneindex2 then
		local pos, ang = self:GetBonePosition(boneindex2)
		if pos then
			self:CreateFootParticle(pos)
		end
	end
end

function meta:AddNotice(message, lifetime, colid)
	if self == MySelf then
		GAMEMODE:AddNotice(message, lifetime, colid)
	end
end

function meta:ParticleEmitter()
	if not self.m_ParticleEmitter then
		self.m_ParticleEmitter = ParticleEmitter(self:GetPos())
		self.m_ParticleEmitter:SetNearClip(24, 32)
	end

	return self.m_ParticleEmitter
end

function meta:GetStatus(sType)
	for _, ent in pairs(ents.FindByClass("status_"..sType)) do
		if ent:GetOwner() == self then return ent end
	end
end

function meta:RemoveAllStatus(bSilent, bInstant)
end

function meta:RemoveStatus(sType, bSilent, bInstant)
end

function meta:GiveStatus(sType, fDie)
end

function meta:GetWeapon(wepclass)
	for _, wep in pairs(self:GetWeapons()) do
		if wep:GetClass() == wepclass then
			return wep
		end
	end
end

function meta:HasWeapon(wepclass)
	return self:GetWeapon(wepclass) ~= nil
end
