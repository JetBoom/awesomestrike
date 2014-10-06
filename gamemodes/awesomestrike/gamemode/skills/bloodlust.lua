SKILL_BLOODLUST = 7

SKILL.Name = "Blood Lust"
SKILL.Description = "Passive\n\nGives 5 health every time you hit an enemy with a melee weapon."
SKILL.Index = SKILL_BLOODLUST

if not SERVER then return end

function SKILL:ProcessOtherDamage(pl, victim, dmginfo)
	if dmginfo:GetInflictor().IsMelee and pl:Alive() and victim:Team() ~= pl:Team() then
		pl:SetHealth(math.min(pl:GetMaxHealthEx(), pl:Health() + 5)) --pl:SetHealth(math.min(pl:GetMaxHealthEx(), pl:Health() + dmginfo:GetDamage() * 0.5))
	end
end
