AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_c4_planted.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	self:SetBombTime(CurTime() + 45)
	self:SetDTFloat(2, 0)
end

util.PrecacheSound("weapons/c4/c4_disarm.wav")
function ENT:UseTarget(pl)
	if pl:Team() == TEAM_CT and not self:GetUsePlayer():IsValid() and pl:GetUseTarget() == self and not pl:GetStateTable().NoDefusing then
		self:SetUseStart(CurTime())
		self:SetUsePlayer(pl)
		self:SetDefuserAvoidPlayers(false)
		self:EmitSound("weapons/c4/c4_disarm.wav")
		pl.LastDefuseAttempt = CurTime()
	end
end

function ENT:SetDefuserAvoidPlayers(avoid)
	local pl = self:GetUsePlayer()
	if pl:IsValid() and pl:IsPlayer() then pl:SetAvoidPlayers(avoid) end
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	local Position = self:GetPos() + self:GetUp() * 32

	self:Fire("kill", "", 0.05)

	local effect = EffectData()
		effect:SetOrigin(Position)
	util.Effect("bomb_explode", effect)

	gamemode.Call("EndRound", TEAM_T)

	util.ScreenShake(Position, 64, 1024, 6, 8192)

	for _, ent in pairs(ents.FindInSphere(Position, 1024)) do
		if ent:IsValid() and ent:IsPlayer() then
			ent:ClearLastAttacker()
			ent:TakeSpecialDamage(200, DMG_DISSOLVE, self, self)
		end
	end

	util.BlastDamage(self, self, Position, 1024, 600)

	self:SetDefuserAvoidPlayers(true)

	for _, ent in pairs(ents.FindByClass("func_bomb_target")) do
		for _, e in pairs(ents.FindInBox(ent:WorldSpaceAABB())) do
			if e == self then
				ent:FireOutput("bombexplode", self, self, 0)
				return
			end
		end
	end
end

function ENT:Think()
	local ct = CurTime()
	if self:GetBombTime() <= ct and self:GetUseStart() == 0 then
		self:Explode()
		return
	end

	if self:GetUseStart() == 0 then return end

	local pl = self:GetUsePlayer()
	if pl:IsValid() and pl:Alive() and pl:GetUseTarget() == self and pl:KeyDown(IN_USE) and not pl:GetStateTable().NoDefusing then
		if 1 <= self:GetUsePercent() and not self.Defused then
			self.Defused = true

			self:SetDefuserAvoidPlayers(true)

			GAMEMODE:AddNotice(pl:Name().." has defused the bomb!~sradio/bombdef.wav")

			GAMEMODE:EndRound(TEAM_CT, true)

			self:Remove()
		else
			self:NextThink(ct)
			return true
		end
	else
		self:SetDefuserAvoidPlayers(true)
		self:SetDTFloat(2, self:GetDTFloat(2) + (CurTime() - self:GetUseStart()) / self.UseDuration)
		self:SetUseStart(0)
		self:SetUsePlayer(NULL)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
