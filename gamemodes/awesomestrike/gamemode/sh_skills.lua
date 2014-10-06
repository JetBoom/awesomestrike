SKILLS = {}

local filelist = file.Find(GM.FolderName.."/gamemode/skills/*.lua", "LUA")
table.sort(filelist)
for _, filename in ipairs(filelist) do
	SKILL = {}

	local skillname = string.sub(filename, 1, -5)
	SKILLNAME = skillname

	include("skills/"..filename)
	AddCSLuaFile("skills/"..filename)

	SKILL.FileName = skillname
	SKILL.Name = SKILL.Name or skillname

	SKILLS[SKILL.Index or -1] = SKILL

	SKILLNAME = nil
	SKILL = nil
end

print("registered "..#SKILLS.." skills.")
