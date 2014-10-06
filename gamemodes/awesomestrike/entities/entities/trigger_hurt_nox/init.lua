-- Probably shouldn't use this. Support for team play maps.

ENT.Type = "brush"

function ENT:Initialize()
	self.Damage = self.Damage or 10
	if self.On == nil then
		self.On = true
	end
	self.DamageRecycle = self.DamageRecycle or 0.5
	if self.DamagePlayers == nil then
		self.DamagePlayers = true
	end
end

function ENT:Think()
end

function ENT:StartTouch(ent)
end

function ENT:EndTouch(ent)
end

function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	if name == "seton" then
		self.On = tonumber(arg) == 1
		return true
	elseif name == "enable" then
		self.On = true
		return true
	elseif name == "disable" then
		self.On = false
		return true
	end
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "damage" then
		self.Damage = tonumber(value) or 0
	elseif key == "starton" then
		self.On = tonumber(value) == 1
	elseif key == "damagerecycle" then
		self.DamageRecycle = tonumber(value) or self.DamageRecycle or 0.5
	elseif key == "damagefilter" then
		value = tonumber(value) or 0
		self.DamagePlayers = bit.band(2, value) == 2
	end
end

function ENT:Touch(ent)
	if self.On and (not ent.NextTriggerNoXHurt or ent.NextTriggerNoXHurt < CurTime()) and 0 < self.Damage then
		if ent:IsPlayer() and (not ent:Alive() or not self.DamagePlayers) then return end

		ent.NextTriggerNoXHurt = CurTime() + self.DamageRecycle

		if ent.TakeSpecialDamage then
			ent:TakeSpecialDamage(self.Damage, DMG_GENERIC, self, self)
		else
			ent:TakeDamage(self.Damage, self, self)
		end
	end
end
