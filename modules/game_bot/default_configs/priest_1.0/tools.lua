-- tools tab
setDefaultTab("Tools")

-- locals
local spyLevel = 1

-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
UI.Button("Ingame macro editor", function(newText)
	UI.MultilineEditorWindow(storage.ingame_macros or "", {title="Macro editor", description="You can add your custom macros (or any other lua code) here"}, function(text)
		storage.ingame_macros = text
		reload()
	end)
end)
UI.Button("Ingame hotkey editor", function(newText)
	UI.MultilineEditorWindow(storage.ingame_hotkeys or "", {title="Hotkeys editor", description="You can add your custom hotkeys/singlehotkeys here"}, function(text)
		storage.ingame_hotkeys = text
		reload()
	end)
end)

UI.Separator()

for _, scripts in ipairs({storage.ingame_macros, storage.ingame_hotkeys}) do
		if type(scripts) == "string" and scripts:len() > 3 then
		local status, result = pcall(function()
			assert(load(scripts, "ingame_editor"))()
		end)
		if not status then 
			error("Ingame edior error:\n" .. result)
		end
	end
end

hotkey("=", "Spy UP", function()
	modules.game_interface.getMapPanel():lockVisibleFloor(posz() - spyLevel)
	spyLevel = spyLevel + 1
end)

hotkey("-", "Spy DOWN", function()
	modules.game_interface.getMapPanel():lockVisibleFloor(posz() + spyLevel)
	spyLevel = spyLevel + 1
end)

hotkey("`", "Free Spy", function()
	modules.game_interface.getMapPanel():unlockVisibleFloor()
	spyLevel = 1
end)

UI.Separator()

UI.Button("Zoom In map [ctrl + =]", function() zoomIn() end)
UI.Button("Zoom Out map [ctrl + -]", function() zoomOut() end)

UI.Separator()

local autoStairs = {1948}
macro(20, "Auto Stairs", "Shift+A", function()
    for x = -1, 1 do
        for y = -1, 1 do
            local tile = g_map.getTile({x = posx() + x, y = posy() + y, z = posz()})
            if tile then
                local things = tile:getThings()
                for _, item in pairs(things) do
                    if table.find(autoStairs, item:getId()) then
                        g_game.use(item)
                    end
                end
            end
        end
    end
end)

UI.Separator()

local c = {
	pickUp = {688, 17012, 5809, 3151, 3199, 3183, 3194, 7883, 3335, 9304, 11701, 4033, 18203, 141, 3187, 9655, 12805, 3163, 11686, 11473, 11475, 6531, 3184, 3169, 669, 3556,
	9306, 10385, 3186, 9653, 11468, 10200, 14684, 788, 9645, 11478, 8096, 14760, 2869, 4033, 12670, 11691, 11486, 16344, 16110, 16105, 13994, 13993, 22733, 22729, 10344, 11455,
	27082, 9304, 9301, 9302, 9303, 12669, 24704, 2853, 3057, 8864, 6126, 3388, 3245, 3043, 9019, 1781, 5948, 6499, 3031, 2785, 12730, 8015, 3040, 3172, 8078, 10278, 123, 140,
	2865, 3253, 10327, 5926, 5466, 9611, 6542, 3035, 10387

	}, -- Item list to pickup, separated by a comma.
	CheckPOS = 1 -- The SQM from your character to check if theres an item.
}
macro(20, "Free Items", "", function()
	for x = -storage.freeItemsPosCheck, storage.freeItemsPosCheck do
		for y = -storage.freeItemsPosCheck, storage.freeItemsPosCheck do
			local tile = g_map.getTile({x = posx() + x, y = posy() + y, z = posz()})
			if tile then
				local things = tile:getThings()
				for _, item in pairs(things) do
					if table.find(c.pickUp, item:getId()) then
						local containers = getContainers()
						for _, container in pairs(containers) do
							g_game.move(item, container:getSlotPosition(container:getItemsCount()), item:getCount())
						end
					end
				end
			end
		end
	end
end)

addTextEdit("freeItemsPosCheck", storage.freeItemsPosCheck or "2", function(widget, text)    
	storage.freeItemsPosCheck = text
end)

UI.Separator()

macro(70, "Spam Spell", "", function()
    say(storage.spamSpellFull)
end)

addTextEdit("spamSpellFull", storage.spamSpellFull or 'Exani hur "up', function(widget, text)    
	storage.spamSpellFull = text
end)

UI.Separator()

local fishingConfig = {
    waterSpots = {633}, -- Water IDs to launch your fishing rod.
    fishingRod = 3483, -- Your fishing rod ID.
    CheckPOS = 5 -- Distance to check water spots to fish (must have the water ID in waterSpots)
}

macro(100, "Auto Fishing", "", function()
    for x = -fishingConfig.CheckPOS, fishingConfig.CheckPOS do
        for y = -fishingConfig.CheckPOS, fishingConfig.CheckPOS do
            local tile = g_map.getTile({x = posx() + x, y = posy() + y, z = posz()})
            if tile then
                local things = tile:getThings()
                for _, item in pairs(things) do
                    if table.find(fishingConfig.waterSpots, item:getId()) then
                        local fr = findItem(fishingConfig.fishingRod)
                        g_game.useWith(fr, item)
                    end
                end
            end
        end
    end
end)

UI.Separator()

singlehotkey("ctrl+f9", "stop alarm", function()
	stopSound()
end)

UI.Separator()

local positionLabel = addLabel("positionLabel", "")
onPlayerPositionChange(function()
  positionLabel:setText("Pos: " .. posx() .. "," .. posy() .. "," .. posz())
end)

UI.Separator()