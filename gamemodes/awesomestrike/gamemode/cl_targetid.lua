local color_black_alpha120 = Color(0, 0, 0, 120)
local color_black_alpha50 = Color(0, 0, 0, 50)

local mins = Vector(-3, -3, -3)
local maxs = Vector(3, 3, 3)
local trace = {mask = MASK_SHOT, mins = mins, maxs = maxs, filter = {}}
function GM:HUDDrawTargetID()
	if not MySelf:IsValid() then return end

	local start = EyePos()
	trace.start = start
	trace.endpos = start + EyeAngles():Forward() * 10240
	trace.filter[1] = MySelf
	trace.filter[2] = MySelf:GetObserverTarget()

	local tr = util.TraceHull(trace)
	local trent = tr.Entity

	if not trent:IsValid() or trent.HUDDrawTargetID and trent:HUDDrawTargetID(tr) or not trent:IsPlayer() or trent:CallStateFunction("SkipTargetID") then return end

	local onmyteam = trent:Team() == MySelf:Team() or not MySelf:Alive()
	if not onmyteam and tr.HitPos:Distance(start) > 1024 then return end

	local x, y = w * 0.5, h * 0.5 + 30
	local col = team.GetColor(trent:Team())

	draw.SimpleText(trent:Nick(), "ass_small_shadow", x, y, col, TEXT_ALIGN_CENTER)

	if onmyteam then
		local health = trent:Health()
		local barw, barh = 100, 8
		local barx, bary = x - barw * 0.5, y - barh - 2

		surface.SetDrawColor(10, 10, 10, 90)
		surface.DrawRect(barx, bary, barw, barh)
		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(barx, bary, barw, barh)
		surface.DrawRect(barx + 2, bary + 2, (barw - 4) * (health / trent:GetMaxHealthEx()), barh - 4)

		local skill = trent:GetSkillTable()
		if skill and skill.Name then
			local texw, texh = surface.GetTextSize("W")
			y = y + texh + 2
			draw.SimpleText("SK: "..skill.Name, "ass_smaller_shadow", x, y, col, TEXT_ALIGN_CENTER)
		end
	end
end

