local activeTimers = {}
local alreadyCounted = {}
local walls = {
    [2129] = 20000,
    [2130] = 45300,
    [7931] = 27000,
    [7928] = 27000,
    [10616] = 60000
}

onAddThing(function(tile, thing)
	if not thing:isItem() then
		return
	end
	local timer = 0
	for id, time in pairs(walls) do
		if thing:getId() == id then
			timer = time
		end
	end

	local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
	if not activeTimers[pos] or activeTimers[pos] < now then
		activeTimers[pos] = now + timer
	end
	tile:setTimer(activeTimers[pos] - now)
end)

onRemoveThing(function(tile, thing)
	if not thing:isItem() then
		return
	end

	for id, time in pairs(walls) do
		if thing:getId() == id and tile:getGround() then
			local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
			activeTimers[pos] = nil
			alreadyCounted[pos] = nil
			tile:setTimer(0)
		end
	end
end)

macro(200, "Shovel Count", "", function()
	for x = -5, 5 do
		for y = -5, 5 do
			local tile = g_map.getTile({x = posx() + x, y = posy() + y, z = posz()})
			if tile then
				if tile:getTopUseThing():getId() == 10616 then
					local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
					if tile:getTimer() > 0 and not alreadyCounted[pos] then
						if tile:getTimer() < 31000 then
							alreadyCounted[pos] = 1
							tile:setTimer(60000)
						end
					end
				end
			end
		end
	end
end)

UI.Separator()