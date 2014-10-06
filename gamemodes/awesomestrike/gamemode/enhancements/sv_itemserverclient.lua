-- Because it would be way too easy to have people deleting each other's stuff, most stuff is handled by the clients themselves.

itemclient = {}

-- Ask for a chip.
function itemclient.RequestChipGeneration(pl)
	-- If we get an ID returned then the item server generated one for us and we should update the player's stuff.
	itemclient.RequestPlayerChips(pl)
end

-- Get this player's entire chip list from the server.
function itemclient.RequestPlayerChips()
end

function itemclient.AcceptHTTP()
end
