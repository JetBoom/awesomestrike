SKILL_KEVLARMASTERY = 2

SKILL.MaxHealth = 125

SKILL.Name = "Kevlar Mastery"
SKILL.ShortName = "K. Mastery"
SKILL.Description = "Passive\n\nIncreases maximum health by "..(SKILL.MaxHealth - 100).."."
SKILL.Index = SKILL_KEVLARMASTERY

if not SERVER then return end

function SKILL:PlayerSpawn(pl)
	local percent = pl:Health() / pl:GetMaxHealthEx()
	pl:SetMaxHealthEx(self.MaxHealth)
	pl:SetHealth(math.min(pl:GetMaxHealthEx() * percent, pl:GetMaxHealthEx()))
end

function SKILL:ChangedTo(pl)
	local percent = pl:Health() / pl:GetMaxHealthEx()
	pl:SetMaxHealthEx(self.MaxHealth)
	pl:SetHealth(math.min(pl:GetMaxHealthEx() * percent, pl:GetMaxHealthEx()))
end

function SKILL:ChangedFrom(pl)
	local percent = pl:Health() / pl:GetMaxHealth()
	pl:SetMaxHealthEx(100)
	pl:SetHealth(math.min(pl:GetMaxHealthEx() * percent, pl:GetMaxHealthEx()))
end
