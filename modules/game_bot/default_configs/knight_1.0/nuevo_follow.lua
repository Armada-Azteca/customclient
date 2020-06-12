UI.Separator()
local followThis = tostring(storage.followLeader)

FloorChangers = {
	Ladders = {
		Up = {1948, 5542, 16693, 16692},
		Down = {432, 412, 469, 1949, 469}
	},

	Holes = {
		Up = {},
		Down = {293, 294, 595, 4728, 385, 9853}
	},

	RopeSpots = {
		Up = {386,},
		Down = {}
	},

	Stairs = {
		Up = {16690, 1958, 7548, 7544, 1952, 1950, 1947, 7542, 855, 856, 1978, 1977, 6911, 6915, 1954, 5259, 20492, 1956, 1957, 1955, 5257},
		Down = {482, 414, 413, 437, 7731, 469, 413, 434, 469, 859, 438, 6127, 566, 7476, 4826}
	},

	Sewers = {
		Up = {},
		Down = {435}
	},
}

local target = followThis
local lastKnownPosition

local function goLastKnown()
	if getDistanceBetween(pos(), {x = lastKnownPosition.x, y = lastKnownPosition.y, z = lastKnownPosition.z}) > 1 then
		local newTile = g_map.getTile({x = lastKnownPosition.x, y = lastKnownPosition.y, z = lastKnownPosition.z})
		if newTile then
			g_game.use(newTile:getTopUseThing())
			delay(math.random(300, 700))
		end
	end
end

local function handleUse(pos)
	goLastKnown()
	local lastZ = posz()
	if posz() == lastZ then
		local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
		if newTile then
			g_game.use(newTile:getTopUseThing())
			delay(math.random(400, 800))
		end
	end
end

local function handleStep(pos)
	goLastKnown()
	local lastZ = posz()
	if posz() == lastZ then
		autoWalk(pos)
		delay(math.random(400, 800))
	end
end

local function handleRope(pos)
	goLastKnown()
	local lastZ = posz()
	if posz() == lastZ then
		local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
		if newTile then
			useWith(3003, newTile:getTopUseThing())
			delay(math.random(400, 800))
		end
	end
end

local floorChangeSelector = {
	Ladders = {Up = handleUse, Down = handleStep},
	Holes = {Up = handleStep, Down = handleStep},
	RopeSpots = {Up = handleRope, Down = handleRope},
	Stairs = {Up = handleStep, Down = handleStep},
	Sewers = {Up = handleUse, Down = handleUse},
}

local function checkTargetPos()
	local c = getCreatureByName(target)
	if c and c:getPosition().z == posz() then
		lastKnownPosition = c:getPosition()
	end
end

local function distance(pos1, pos2)
	local pos2 = pos2 or lastKnownPosition or pos()
	return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

local function executeClosest(possibilities)
	local closest
	local closestDistance = 99999
	for _, data in ipairs(possibilities) do
		local dist = distance(data.pos)
		if dist < closestDistance then
			closest = data
			closestDistance = dist
		end
	end

	if closest then
		closest.changer(closest.pos)
	end
end

local function handleFloorChange()
	local c = getCreatureByName(target)
	local range = 2
	local p = pos()
	local possibleChangers = {}
	for _, dir in ipairs({"Down", "Up"}) do
		for changer, data in pairs(FloorChangers) do
			for x = -range, range do
				for y = -range, range do
					local tile = g_map.getTile({x = p.x + x, y = p.y + y, z = p.z})
					if tile then
						if table.find(data[dir], tile:getTopUseThing():getId()) then
							table.insert(possibleChangers, {changer = floorChangeSelector[changer][dir], pos = {x = p.x + x, y = p.y + y, z = p.z}})
						end
					end
				end
			end
		end
	end
	executeClosest(possibleChangers)
end

local function targetMissing()
	for _, n in ipairs(getSpectators(false)) do
		if n:getName() == target then
			return n:getPosition().z ~= posz()
		end
	end
	return true
end

macro(500, "Advanced Follow", "", function(macro)
	local c = getCreatureByName(target)

	if g_game.isFollowing() then
		if g_game.getFollowingCreature() ~= c then
			g_game.cancelFollow()
			g_game.follow(c)
		end
	end

	if c and not g_game.isFollowing() then
		g_game.follow(c)
	elseif c and g_game.isFollowing() and getDistanceBetween(pos(), c:getPosition()) > 1 then
		g_game.cancelFollow()
		g_game.follow(c)
	end

	checkTargetPos()
	if targetMissing() and lastKnownPosition then
		handleFloorChange()
	end
end)

UI.Label("Follow Player:")
addTextEdit("playerToFollow", storage.followLeader or "Trala", function(widget, text)
	storage.followLeader = text
	target = tostring(text)
end)