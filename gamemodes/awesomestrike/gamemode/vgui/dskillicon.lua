local PANEL = {}

function PANEL:GetSlot()
	return -1
end

function PANEL:GetSlotText()
	return "S"
end

function PANEL:GetDisplayName()
	local skilltab = SKILLS[GetConVarNumber("awesomestrike_skill")]
	if skilltab then
		return skilltab.ShortName or skilltab.Name
	end
end

vgui.Register("DSkillIcon", PANEL, "DWeaponIcon")
