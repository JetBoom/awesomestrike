GM.Help = [[<html>

<head>

<style>
	body
	{
		background-color:black;
		font-family:tahoma,verdana,arial;
		font-size:8pt;
		color:white;
		padding:4px;
		padding-right:16px;
	}
	tr
	{
		border-top,border-bottom:1px dotted white;
	}
	h4
	{
		font-weight:bolder;
		text-decoration:underlined;
		font-size:12pt;
		margin-bottom:10px;
		color:EEEE00;
	}
	table
	{
		font-size:8pt;
		width:90%;
		margin-left:auto;
		margin-right:auto;
	}
</style>

</head>

<body>

<h4>Synopsis</h4>
Awesome Strike is an attempt to create a cooler version of Counter-Strike and other tactical shooters while bringing in elements from fast-paced action games like DMC, S4, and GunZ. 
Bullets are physical and take time to travel and objectives are remade to be in the faster-paced environment.
<br><br>
<span style="color:red;text-decoration:underlined">It's strongly recommended that you have Counter-Strike: Source or its resource pack installed. If not then you may have missing textures and models.</span>

<h4>Controls</h4>
<table rules="rows">
	<thead>
		<th width="25%">Key</th>
		<th width="75%">Action</th>
	</thead>
	<tbody>
		<tr>
			<td>SPRINT (Default: Shift)</td>
			<td>While not on ground and next to wall: WALL RUN
			</td>
		</tr>
		<tr>
			<td>JUMP (Default: Space)</td>
			<td>While holding left strafe: DODGE LEFT<br>
			While holding right strafe: DODGE RIGHT<br>
			While sliding: SLIDE JUMP<br>
			While not on ground and facing wall: WALL JUMP<br>
			</td>
		</tr>
		<tr>
			<td>WALK (Default: Alt)</td>
			<td>ACTIVATE SKILL</td>
		</tr>
		<tr>
			<td>DUCK (Default: Ctrl)</td>
			<td>While sprinting: GROUND SLIDE</td>
		</tr>
		<tr>
			<td>F1</td>
			<td>Help</td>
		</tr>
		<tr>
			<td>F2</td>
			<td>Change team / spectate</td>
		</tr>
		<tr>
			<td>F3</td>
			<td>Equipment menu (while in a buy zone)</td>
		</tr>
		<tr>
			<td>F4</td>
			<td>Radio</td>
		</tr>
	</tbody>
</table>

<h4>How to play</h4>
When the round starts, all players are frozen for a few seconds. Use this time to select your weaponry. Each player can carry up to three weapons. Press F3 while in a buy zone to get new weapons. 
A <span style="color:limegreen">green</span> notice appears center-right on the screen when you can do certain actions like buying weapons.
<br><br>
Once you are unfrozen, use tactics and skill to complete the objectives and kill the other team. 
If you happen to die, don't worry! You can respawn in ]]..GM.RespawnTime..[[ seconds or have a team member revive you.

<h4>Objectives</h4>
There are a bunch of different objectives depending on the map. A round ends when:
<ul>
<li>A bomb is successfully detonated by the terrorists.</li>
<li>A bomb is disarmed by the counter-terrorists.</li>
<li>All hostages are rescued by the counter-terrorists.</li>
<li>All the members of a team have died once if there are no bomb targets or hostages.</li>
</ul>

<h4>Tips and other info</h4>
<ul>
<li>Bullets take time to travel. Lead your shots or use the Smart Rifle or Smart Targeting skill.</li>
<li>There are no head shots or damage bonuses for hitting vital areas. Focus on hitting your target, not hitting their head.</li>
<li>The Awesome Rifle and Awesome Launcher can be shot without guiding capabilities by pressing right click.</li>
<li>The Knife does triple damage in the back and thrown knives deal damage based on air time.</li>
<li>Walls can be climbed by wall jumping and then dodging in to the wall repeatedly.</li>
<li>Attacking while dodging will cancel the dodge, allowing you to keep your velocity.</li>
<li>Stay on the move. It's much harder to hit moving targets especially when bullets take time to travel.</li>
<li>Sliding in to props can bash them in to other players, potentially killing them.</li>
<li>Hostages can't be killed no matter how much you beat on them.</li>
<li>You will respawn after some time but team members can revive you on the spot to save precious seconds in travel time.</li>
<li>Weapons such as grenades have cool down times. After using them you will get a new one after a few seconds.</li>
<li>The Mechanical Mastery skill halves the cooldown time on things like grenades and detonation packs.</li>
<li>Use voice chat.</li>
</ul>

<h4>Credits</h4>
Created by William "JetBoom" Moodhe<br>
williammoodhe@gmail.com<br>
noxiousnet.com

</body>

</html>]]

local Window
function GM:ShowHelp()
	if Window then
		Window:SetVisible(true)
		Window:MakePopup()
		return
	end

	local wide = 480
	local tall = 480

	Window = vgui.Create("DFrame")
	Window:SetSize(wide, tall)
	Window:SetTitle("Help")
	Window:SetDeleteOnClose(false)

	local html = vgui.Create("DHTML", Window)
	html:StretchToParent(8, 32, 8, 40)
	html:SetHTML(GAMEMODE.Help)

	local button = EasyButton(Window, "Close", 16, 8)
	button:AlignBottom(8)
	button:CenterHorizontal()
	button.DoClick = function(btn) btn:GetParent():Close() end

	Window:Center()
	Window:MakePopup()

	DrawStylishBackground(Window)
end
