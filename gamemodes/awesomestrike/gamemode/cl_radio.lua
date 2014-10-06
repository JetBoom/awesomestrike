GM.RadioStations = {
	{
		Name = "Trance",
		Stations = {
			{"DIGITALLY IMPORTED - Trance", "http://u12.di.fm/di_trance"},
			{"DIGITALLY IMPORTED - Psychedelic Trance", "http://u17.di.fm/di_goapsy"}
		}
	},
	{
		Name = "Techno",
		Stations = {
			{"DIGITALLY IMPORTED - Techno", "http://u12.di.fm/di_techno"}
		}
	},
	{
		Name = "Drum 'n Bass",
		Stations = {
			{"DIGITALLY IMPORTED - Drum 'n Bass", "http://u16b.di.fm/di_drumandbass"}
		}
	},
	{
		Name = "House",
		Stations = {
			{"DIGITALLY IMPORTED - House", "http://u12b.di.fm/di_techhouse"}
		}
	}
}

local CVGenre = CreateClientConVar("awesomestrike_radio_genre", 1, true, true)
local CVStation = CreateClientConVar("awesomestrike_radio_station", 1, true, true)
local CVVolume = CreateClientConVar("awesomestrike_radio_volume", 60, true, true)
local CVStartOn = CreateClientConVar("awesomestrike_radio_starton", 0, true, true)

function GM:CreateRadioPanel()
	if self.RadioControlPanel and self.RadioControlPanel:Valid() then
		self.RadioControlPanel:SetVisible(true)
		return
	end

	
end

function GM:CreateRadio(genre, channel, volume)
	self:DestroyRadio()

	genre = genre or CVGenre:GetInt()
	channel = channel or CVStation:GetInt()
	volume = volume or CVVolume:GetInt()

	local html = vgui.Create("DHTML")
	self.RadioPanel = html
	html:SetSize(1, 1)
	html:SetVisible(false)
	html:SetMouseInputEnabled(false)
	html:SetKeyboardInputEnabled(false)

	local genre = self.RadioStations[genre]
	if not genre then return end
	local station = genre.Stations[channel]
	if not station or not station[2] then return end

	html:SetHTML([[<html>
	<head>
	</head>
	<body>
	<embed type="application/x-shockwave-flash" flashvars="audioUrl=]].. station[2] ..[[&autoPlay=true&playermode=mini" src="http://www.google.com/reader/ui/3523697345-audio-player.swf" width="400" height="27" quality="best"></embed>
	</body>
	</html>]])
end

function GM:DestroyRadio()
	if self.RadioPanel and self.RadioPanel:Valid() then
		self.RadioPanel:Remove()
	end
	self.RadioPanel = nil
end

function GM:ToggleRadio()
	if self.RadioPanel and self.RadioPanel:Valid() then
		self:DestroyRadio()
		MySelf:ChatPrint("Radio off.")
	else
		self:CreateRadio(1, 1)
		MySelf:ChatPrint("Radio on.")
	end
end
