local Notice = {}

local fontNotice = "ass_small"
local texGrad = surface.GetTextureID("gui/gradient")
local function DrawNotice(notice, y, screenscale)
	local x = w * 0.5
	local fadein = math.Clamp(math.min(notice.EndTime - CurTime(), CurTime() - notice.StartTime) * 4, 0, 1)

	surface.SetFont(fontNotice)
	local texw, texh = surface.GetTextSize(notice.Message)
	local boxheight = math.ceil(texh + 6 * screenscale)
	local boxwidth = 400 * screenscale

	local lerp = (boxwidth * 0.5 + (1 - fadein) * boxwidth * 0.375)

	surface.SetTexture(texGrad)
	surface.SetDrawColor(5, 5, 5, fadein * 120)
	surface.DrawTexturedRectRotated(x - lerp, y + boxheight * 0.5, boxwidth, boxheight + 1, 180)
	surface.DrawTexturedRectRotated(x + lerp, y + boxheight * 0.5, boxwidth, boxheight + 1, 0)

	notice.Color.a = fadein * 255

	draw.SimpleText(notice.Message, fontNotice, x, y + boxheight * 0.5 - texh * 0.5, notice.Color, TEXT_ALIGN_CENTER)

	return y + boxheight
end

function GM:DrawNotice(screenscale)
	if #Notice == 0 then return end

	local y = 0
	local ct = CurTime()
	for k, v in ipairs(Notice) do
		if ct < v.EndTime then
			y = DrawNotice(v, y, screenscale)
		end
	end

	if done then
		Notice = {}
	end
end

function GM:AddNotice(message, lifetime, color)
	local text, snd = string.match(message, "(.+)~s(.+)")
	if text and snd then
		message = text
		if snd ~= "nil" then
			surface.PlaySound(snd)
		end
	end

	local notice = {}
	notice.Message = message
	notice.StartTime = CurTime()
	notice.Color = color and table.Copy(color) or Color(255, 255, 255, 255) 
	notice.EndTime = notice.StartTime + (lifetime or 5)
	table.insert(Notice, notice)

	if #Notice > 8 then
		table.remove(Notice, 1)
	end
end

local ColorIDs = {
	[COLID_DEFAULT] = Color(230, 230, 60),
	[COLID_RED] = Color(255, 20, 20),
	[COLID_GREEN] = Color(20, 255, 20),
	[COLID_YELLOW] = Color(255, 255, 0),
	[COLID_BLUE] = Color(0, 100, 255),
	[COLID_WHITE] = Color(255, 255, 255)
}
usermessage.Hook("AddNotice", function(um)
	GAMEMODE:AddNotice(um:ReadString(), um:ReadFloat(), ColorIDs[um:ReadShort()] or color_white)
end)
