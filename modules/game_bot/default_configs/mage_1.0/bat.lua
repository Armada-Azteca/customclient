-- tools tab
local batTab = setDefaultTab("bat")

-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
UI.Separator()

-- locals
local enemies = {
  "Ejemplo Char Uno", "Ejemplo Char Dos"
}
local removeId = 688
local wallIds = {2129, 7928, 7931}
local walkKeys = {"W", "A", "S", "D", "Q", "E", "Z", "C"}
local dashKeys = {"W", "A", "S", "D"}
--local dashKeys = {"Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad6", "Numpad7", "Numpad8", "Numpad9"}

UI.Button("Ingame macro editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_macros_bat or "", {title="Macro editor", description="You can add your custom macros (or any other lua code) here"}, function(text)
	storage.ingame_macros_bat = text
	reload()
  end)
end)

UI.Button("Ingame hotkey editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_hotkeys_bat or "", {title="Hotkeys editor", description="You can add your custom hotkeys/singlehotkeys here"}, function(text)
	storage.ingame_hotkeys_bat = text
	reload()
  end)
end)

for _, scripts in ipairs({storage.ingame_macros_bat, storage.ingame_hotkeys_bat}) do
  if type(scripts) == "string" and scripts:len() > 3 then
	local status, result = pcall(function()
	  assert(load(scripts, "ingame_editor"))()
	end)
	if not status then 
	  error("Ingame edior error:\n" .. result)
	end
  end
end
UI.Separator()

macro(200, "UH Anti-Paralyze", "", function()
	if not isParalyzed() then return end
	usewith(3187, player)
end)

UI.Separator()

function UHfriendHealer(parent)
  local panelName = "UHadvancedFriendHealer"
  local ui = setupUI([[
Panel
  height: 145
  margin-top: 2

  BotSwitch
    id: title
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text-align: center
    text: Uh Healer

  BotTextEdit
    id: UHId
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: title.bottom
    margin-top: 3

  Button
    id: editList
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: center
    text: Edit List
    margin-top: 3

  SmallBotSwitch
    id: partyAndGuildMembers
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: center
    text: Heal Party/Guild
    margin-top: 3

  BotLabel
    id: manaInfo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: partyAndGuildMembers.bottom
    text-align: center

  HorizontalScrollBar
    id: minMana
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: manaInfo.bottom
    margin-top: 2
    minimum: 1
    maximum: 100
    step: 1

  BotLabel
    id: friendHp
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    text-align: center

  HorizontalScrollBar
    id: minFriendHp
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.top: friendHp.bottom
    margin-right: 2
    margin-top: 2
    minimum: 1
    maximum: 100
    step: 1
    
  HorizontalScrollBar
    id: maxFriendHp
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.top: prev.top
    margin-left: 2
    minimum: 1
    maximum: 100
    step: 1    
  ]], parent)
  ui:setId(panelName)

  if not storage[panelName] then
    storage[panelName] = {
      minMana = 60,
      minFriendHp = 40,
	  maxFriendHp = 90,
	  UHId = 3187,
      UHList = {},
      partyAndGuildMembers = true
    }
  end


  rootWidget = g_ui.getRootWidget()
  UHListWindow = g_ui.createWidget('UHListWindow', rootWidget)
  UHListWindow:hide()

  if storage[panelName].UHList and #storage[panelName].UHList > 0 then
    for _, UHName in ipairs(storage[panelName].UHList) do
      local label = g_ui.createWidget("UHFriendName", UHListWindow.UHList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[panelName].UHList, label:getText())
        label:destroy()
      end
      label:setText(UHName)
    end
  end

  UHListWindow.UHAddFriend.onClick = function(widget)
    local friendName = UHListWindow.UHFriendName:getText()
    if friendName:len() > 0 and not table.contains(storage[panelName].UHList, friendName, true) then
      table.insert(storage[panelName].UHList, friendName)
      local label = g_ui.createWidget("UHFriendName", UHListWindow.UHList)
      label.remove.onClick = function(widget)
        table.removevalue(storage[panelName].UHList, label:getText())
        label:destroy()
      end
      label:setText(friendName)
      UHListWindow.UHFriendName:setText('')
    end
  end

  ui.title:setOn(storage[panelName].enabled)
  ui.partyAndGuildMembers:setOn(storage[panelName].partyAndGuildMembers)

  ui.title.onClick = function(widget)
    storage[panelName].enabled = not storage[panelName].enabled
    widget:setOn(storage[panelName].enabled)
  end

  ui.partyAndGuildMembers.onClick = function(widget)
    storage[panelName].partyAndGuildMembers = not storage[panelName].partyAndGuildMembers
    widget:setOn(storage[panelName].partyAndGuildMembers)
  end
  ui.editList.onClick = function(widget)
    UHListWindow:show()
    UHListWindow:raise()
    UHListWindow:focus()
  end
  ui.UHId.onTextChange = function(widget, text)
    storage[panelName].UHId = text
  end
  local updateMinManaText = function()
    ui.manaInfo:setText("Minimum Mana >= " .. storage[panelName].minMana)
  end
  local updateFriendHpText = function()
    ui.friendHp:setText("" .. storage[panelName].minFriendHp .. "% <= hp >= " .. storage[panelName].maxFriendHp .. "%")  
  end

  ui.minMana.onValueChange = function(scroll, value)
    storage[panelName].minMana = value
    updateMinManaText()
  end
  ui.minFriendHp.onValueChange = function(scroll, value)
    storage[panelName].minFriendHp = value

    updateFriendHpText()
  end
  ui.maxFriendHp.onValueChange = function(scroll, value)
    storage[panelName].maxFriendHp = value
    updateFriendHpText()
  end
  ui.UHId:setText(storage[panelName].UHId)
  ui.minMana:setValue(storage[panelName].minMana)
  ui.minFriendHp:setValue(storage[panelName].minFriendHp)
  ui.maxFriendHp:setValue(storage[panelName].maxFriendHp)

  macro(200, function()
    if storage[panelName].enabled and storage[panelName].UHId:len() > 0 and manapercent() > storage[panelName].minMana then
	  for _, spec in ipairs(getSpectators()) do
		if spec:isPlayer() and spec:getHealthPercent() >= storage[panelName].minFriendHp and spec:getHealthPercent() <= storage[panelName].maxFriendHp then
		  if storage[panelName].partyAndGuildMembers and (spec:getShield() >= 3 or spec:getEmblem() == 1) then
				useWith(tonumber(storage[panelName].UHId), spec)
          end
		  if table.contains(storage[panelName].UHList, spec:getName()) then
			useWith(tonumber(storage[panelName].UHId), spec)
          end
        end
      end
    end
  end)
end
UHfriendHealer(batTab)

UI.Separator()

macro(100, "Auto Enemies", "Shift+F11", function()
  for _, n in ipairs(getSpectators(false)) do
	  for _, e in pairs(enemies) do
		  local current = g_game.getAttackingCreature()
		  if current and table.find(enemies, current:getName()) then
			  return true
		  end

		  if n:isPlayer() and n:getName() == e and getDistanceBetween(pos(), n:getPosition()) <= 7 then
			  g_game.cancelAttack()
			  g_game.attack(n)
		  end
	  end
  end
end)

UI.Separator()

local remover = addSwitch("autoRemove", "Activar AutoRemover", function(widget)
  storage.autoRemove = not storage.autoRemove
  widget:setOn(storage.autoRemove)
  end, miscTab)
remover:setOn(storage.autoRemove)

function autoRemoveWalls(this)
  local tile = this
  if tile then
	  local things = tile:getThings()
	  for _, item in pairs(things) do
		  if table.find(wallIds, item:getId()) then
			  usewith(removeId, tile:getTopUseThing())
		  end
	  end
  end
end

onKeyPress(function(keys)
  if storage.autoRemove then
	  if table.find(walkKeys, keys) then
		  local directions = {
			  ["W"] = g_map.getTile({x = posx(), y = posy() - 1, z = posz()}),
			  ["A"] = g_map.getTile({x = posx() - 1, y = posy(), z = posz()}),
			  ["S"] = g_map.getTile({x = posx(), y = posy() + 1, z = posz()}),
			  ["D"] = g_map.getTile({x = posx() + 1, y = posy(), z = posz()}),
			  ["Q"] = g_map.getTile({x = posx() - 1, y = posy() - 1, z = posz()}),
			  ["E"] = g_map.getTile({x = posx() + 1, y = posy() - 1, z = posz()}),
			  ["Z"] = g_map.getTile({x = posx() - 1, y = posy() + 1, z = posz()}),
			  ["C"] = g_map.getTile({x = posx() + 1, y = posy() + 1, z = posz()})
		  }
		  local thisWall = directions[keys]
		  autoRemoveWalls(thisWall)
	  end
  end
end)

local dash = addSwitch("dashWalk", "Activar Dash", function(widget)
  storage.dashWalk = not storage.dashWalk
  widget:setOn(storage.dashWalk)
  end, miscTab)
dash:setOn(storage.dashWalk)

-- onKeyPress(function(keys)
--   if storage.dashWalk then
-- 	  if table.find(dashKeys, keys) then
-- 		  local direction = {
-- 			  ["Numpad8"] = 0,
-- 			  ["Numpad6"] = 1,
-- 			  ["Numpad2"] = 2,
-- 			  ["Numpad4"] = 3,
-- 			  ["Numpad9"] = 4,
-- 			  ["Numpad3"] = 5,
-- 			  ["Numpad1"] = 6,
-- 			  ["Numpad7"] = 7
-- 		  }
-- 		  local thisDash = direction[keys]
-- 		  for i = 10, 1, -1 do
-- 			  if i > 1 then
-- 			  g_game.walk(thisDash)
-- 			  end
-- 		  end
-- 	  end
--   end
-- end)

onKeyPress(function(keys)
	if storage.dashWalk then
		if table.find(dashKeys, keys) then
			local direction = {
				["W"] = 0,
				["A"] = 3,
				["S"] = 2,
				["D"] = 1
			}
			local thisDash = direction[keys]
			for i = 10, 1, -1 do
				if i > 1 then
				g_game.walk(thisDash)
				end
			end
		end
	end
  end)

UI.Separator()

local minas = {
  minasId = {6493}, -- Item list to pickup, separated by a comma.
  CheckPOS = 7 -- The SQM from your character to check if theres an item.
}

local minasPosition = {}

macro(20, "Revelar Minas", "", function()
  for x = -minas.CheckPOS, minas.CheckPOS do
	  for y = -minas.CheckPOS, minas.CheckPOS do
		  local tile = g_map.getTile({x = posx() + x, y = posy() + y, z = posz()})
		  if tile then
			  local things = tile:getThings()
			  for _, item in pairs(things) do
				  if table.find(minas.minasId, item:getId()) and minasPosition[tile] ~= 1 then
					  tile:setFill('red')
					  minasPosition[tile] = 1            
				  elseif minasPosition[tile] == 1 and not table.find(minas.minasId, item:getId()) then
					  minasPosition[tile] = nil
				  end
			  end
		  end
	  end
  end
end)

UI.Separator()

macro(100, "Auto FireBomb", "", function()
	for x = -7, 7 do
		for y = -7, 7 do
			local xp = posx()
			local yp = posy()
			local tile = g_map.getTile({x = xp + x, y = yp + y, z = posz()})
			if tile then
				local a = tile:getEffects()[1]
				if a then 
					if a:getId() ~= 51 then return end
				end
			end
			if tile then
				for k, v in pairs(tile:getEffects()) do
					if v:getId() == 51 then
						local newTile = g_map.getTile({x = tile:getPosition().x + 1, y = tile:getPosition().y + 1, z = posz()})
						usewith(3192, newTile:getTopUseThing())
						delay(2000)
					end
				end
			end
		end
	end
end)

UI.Separator()

Panels.AttackItem(batTab)

UI.Separator()

UI.Label("Mana training")
if type(storage.manaTrain) ~= "table" then
  storage.manaTrain = {on=false, title="MP%", text="utevo lux", min=80, max=100}
end

local manatrainmacro = macro(1000, function()
  local mana = math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))
  if storage.manaTrain.max >= mana and mana >= storage.manaTrain.min then
	say(storage.manaTrain.text)
  end
end)
manatrainmacro.setOn(storage.manaTrain.on)

UI.DualScrollPanel(storage.manaTrain, function(widget, newParams) 
  storage.manaTrain = newParams
  manatrainmacro.setOn(storage.manaTrain.on)
end)

UI.Separator()

Panels.AttackLeaderTarget(batTab)

UI.Separator()

Panels.AntiPush(batTab)

UI.Separator()

macro(500, "Spell en X Creaturas", nil, function()
	local amount = 0
    for _, n in ipairs(getSpectators(false)) do
        if n:isMonster() and getDistanceBetween(pos(), n:getPosition()) <= 3 then
            amount = amount + 1
        end
    end

    if amount >= tonumber(storage.spellLanzarCantidad) then
        say(storage.spellSpamLanzar)
    end
end)

UI.Label("Lanzar en X Cantidad:")
addTextEdit("spellLanzarCantidad", storage.spellLanzarCantidad or "8", function(widget, text)    
	storage.spellLanzarCantidad = text
end)

UI.Label("Spell a Lanzar:")
addTextEdit("spellSpamLanzar", storage.spellSpamLanzar or "exura vis deluxe", function(widget, text)    
	storage.spellSpamLanzar = text
end)

UI.Separator()

Panels.LimitFloor(batTab)

UI.Separator()

macro(200, "Revelar Creaturas Inv", nil, function()
    for _, n in ipairs(getSpectators(false)) do
		if n:isMonster() and n:isInvisible() then
			local outfit = n:getOutfit()
			n:setOutfit(outfit)
        end
    end
end)

UI.Separator()