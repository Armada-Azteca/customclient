-- tools tab
setDefaultTab("bot")

-- Locals
local boosterId = 17012

-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
UI.Separator()

UI.Button("Ingame macro editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_macros_bot or "", {title="Macro editor", description="You can add your custom macros (or any other lua code) here"}, function(text)
	storage.ingame_macros_bot = text
	reload()
  end)
end)

UI.Button("Ingame hotkey editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_hotkeys_bot or "", {title="Hotkeys editor", description="You can add your custom hotkeys/singlehotkeys here"}, function(text)
	storage.ingame_hotkeys_bot = text
	reload()
  end)
end)

for _, scripts in ipairs({storage.ingame_macros_bot, storage.ingame_hotkeys_bot}) do
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

macro(25000, "Booster User", "", function()
  use(boosterId)
end)

UI.Separator()

function seleccionarMonster(distancia, cantidad, distanciaSelf)
	if not distancia or not cantidad or not distanciaSelf then return end
	for _, n in ipairs(getSpectators(false)) do
		if n:isMonster() and getDistanceBetween(pos(), n:getPosition()) <= distanciaSelf then
			local count = checkMonsterBox(n, distancia)
			if count >= cantidad then
				return n
			end
		end
	end
	return false
end

function checkMonsterBox(m, distancia)
	if not m or not distancia then return end
	local count = 0
	for _, c in ipairs(g_map.getSpectators(m:getPosition(), false)) do
		if c:isMonster() and getDistanceBetween(m:getPosition(), c:getPosition()) <= distancia then
			count = count + 1
		end
	end
	return count
end

activarCavebot = macro(500, "Activar CaveBot", "", function()
	local shotId = tonumber(storage.shotRuneId)
	local amount = 0
	local players = 0
	local target = nil
	local checar = nil

	if storage.runeTarget then
		checar = tonumber(storage.runaEnTarget)
	elseif not storage.runeTarget then
		checar = tonumber(storage.runeEnSelf)
	end

	for _, n in ipairs(getSpectators(false)) do
		if n:isMonster() and getDistanceBetween(pos(), n:getPosition()) <= checar then
			amount = amount + 1
			target = n
		elseif n:isPlayer() and n:getName() ~= name() then
			players = players + 1
		end
	end

	if storage.runeTarget and storage.runeSelf then
		activarCavebot.setOff()
		TargetBot.setOff()
		CaveBot.setOff()
		g_game.cancelAttack()
		talkPrivate(name(), "No puedes tener activado Runa Target y Runa Self a la ves, desactivado uno.")
		return
	end

	if amount >= tonumber(storage.pararTargetEnCantidad) and not storage.runeTarget then
		CaveBot.setOff()
		TargetBot.setOn()
		if storage.huntWithSpell and not storage.runeSelf then
			if manapercent() >= tonumber(storage.spellBotOnMana) and TargetBot.isOn() then
				say(storage.spellBotLanzar)
			end
		elseif storage.runeSelf and storage.huntWithSpell then
			if manapercent() >= tonumber(storage.spellBotOnMana) and TargetBot.isOn() then
				say(storage.spellBotLanzar)
			elseif manapercent() < tonumber(storage.spellBotOnMana) and TargetBot.isOn() then
				usewith(shotId, player)
			end
		elseif storage.runeSelf and not storage.huntWithSpell then
			if TargetBot.isOn() then
				usewith(shotId, player)
			end
		end
		return
	elseif amount < tonumber(storage.pararTargetEnCantidad) and not storage.runeTarget then
		CaveBot.setOn()
		TargetBot.setOff()
		g_game.cancelAttack()
	end

	if storage.runeTarget and not storage.runeSelf then
		local seleccionarTarget = seleccionarMonster(tonumber(storage.runaEnTarget), tonumber(storage.runaEnCatidad), 6)
		local seleccionarSpell = seleccionarMonster(tonumber(storage.runeEnSelf), tonumber(storage.pararTargetEnCantidad), tonumber(storage.runeEnSelf))

		if not seleccionarTarget and storage.runeTarget and not storage.huntWithSpell then
			CaveBot.setOn()
			TargetBot.setOff()
			g_game.cancelAttack()
		elseif not seleccionarTarget and not seleccionarSpell and storage.runeTarget and storage.huntWithSpell then
			CaveBot.setOn()
			TargetBot.setOff()
			g_game.cancelAttack()
		end

		if storage.runeTarget and not storage.huntWithSpell then
			if seleccionarTarget then
				CaveBot.setOff()
				TargetBot.setOn()
				usewith(shotId, seleccionarTarget)
			end
		elseif storage.runeTarget and storage.huntWithSpell then
			if manapercent() >= tonumber(storage.spellBotOnMana) and seleccionarSpell then
				CaveBot.setOff()
				TargetBot.setOn()
				say(storage.spellBotLanzar)
			elseif manapercent() < tonumber(storage.spellBotOnMana) and seleccionarSpell then
				CaveBot.setOff()
				TargetBot.setOn()
				usewith(shotId, seleccionarSpell)
			end
		end
	end
end)

local huntWithSpell = addSwitch("huntWithSpell", "Activar Hunt Spell", function(widget)
	storage.huntWithSpell = not storage.huntWithSpell
	widget:setOn(storage.huntWithSpell)
end)
huntWithSpell:setOn(storage.huntWithSpell)

local runeTarget = addSwitch("runeTarget", "Activar Runa Target", function(widget)
	storage.runeTarget = not storage.runeTarget
	widget:setOn(storage.runeTarget)
end)
runeTarget:setOn(storage.runeTarget)

local runeSelf = addSwitch("runeSelf", "Activar Runa Self", function(widget)
	storage.runeSelf = not storage.runeSelf
	widget:setOn(storage.runeSelf)
end)
runeSelf:setOn(storage.runeSelf)

UI.Label("Pausar en X monsters:")
addTextEdit("pararTargetEnCantidad", storage.pararTargetEnCantidad or "5", function(widget, text)
	storage.pararTargetEnCantidad = text
end)

UI.Label("Lanzar en X monsters:")
addTextEdit("runaEnCatidad", storage.runaEnCatidad or "24", function(widget, text)
	storage.runaEnCatidad = text
end)

UI.Label("Distancia monsters (Target):")
addTextEdit("runaEnTarget", storage.runaEnTarget or "2", function(widget, text)
	storage.runaEnTarget = text
end)

UI.Label("Distancia monsters (Spell - Self):")
addTextEdit("runeEnSelf", storage.runeEnSelf or "2", function(widget, text)
	storage.runeEnSelf = text
end)

UI.Label("Runa a Lanzar:")
addTextEdit("shotRuneId", storage.shotRuneId or "3151", function(widget, text)
	storage.shotRuneId = text
end)

UI.Label("Spell en Mana:")
addTextEdit("spellBotOnMana", storage.spellBotOnMana or "80", function(widget, text)
	storage.spellBotOnMana = text
end)

UI.Label("Spell a Lanzar:")
addTextEdit("spellBotLanzar", storage.spellBotLanzar or "exevo gran mas chupala", function(widget, text)
	storage.spellBotLanzar = text
end)

UI.Separator()

macro(500, "Alarm on PK Red", "", function()
  local skull = skull()
  if skull >= 3 then
	  playAlarm()
  end
end)

local safeList = {"Boom Locote"}
macro(500, "Alarm on player screen", "", function()
	local players = 0
	for _, n in ipairs(getSpectators(false)) do
		if n:isPlayer() and n:getName() ~= name() and n:getShield() < 3 and n:getEmblem() ~= 1 and not table.find(safeList, n:getName()) then
			players = players + 1
		end
	end

	if players > 0 then
		playAlarm()
	end
end)

UI.Separator()

macro(200, "Alarm on World Chat(PM)", "", function()
	local chnl = getChannelId("World Chat")
	local pm = getChannelId(tostring(storage.enviarMsgA))
	local zona = tostring(storage.zoneAlarm)
	local individual = "El jugador %s va para %s."
	local varios = "Los jugadores: %s - van para %s."
	local players = 0
	local names = ''
	for _, n in ipairs(getSpectators(false)) do
		if n:isPlayer() and n:getName() ~= name() then
			players = players + 1
			if players > 1 then
				names = ""..names.." y "..n:getName()..""
			else
				names = names .. n:getName()
			end
		end
	end

	if players == 1 then
		local msg = string.format(individual, names, zona)
		--sayChannel(chnl, msg)
		talkPrivate(tostring(storage.enviarMsgA), msg)
		names = ''
		delay(5000)
	elseif players > 1 then
		local msg = string.format(varios, names, zona)
		--sayChannel(chnl, msg)
		talkPrivate(tostring(storage.enviarMsgA), msg)
		names = ''
		delay(5000)
	end
end)

local autoPMName = addSwitch("alarmaOnMessage", "Activar Alarma (PM)", function(widget)
	storage.alarmaOnMessage = not storage.alarmaOnMessage
	widget:setOn(storage.alarmaOnMessage)
	end, miscTab)
autoPMName:setOn(storage.alarmaOnMessage)

onTalk(function(name, level, mode, text, channelId, pos)
	if storage.alarmaOnMessage then
		if mode == 4 and name == tostring(storage.sonarAlarmaA) then
			playAlarm()
			delay(2000)
		end
	end
end)

UI.Label("Nombre de Zona:")
addTextEdit("zoneAlarm", storage.zoneAlarm or "Nada", function(widget, text)    
	storage.zoneAlarm = text
end)

UI.Label("Enviar MSG A:")
addTextEdit("enviarMsgA", storage.enviarMsgA or "Ponid", function(widget, text)    
	storage.enviarMsgA = text
end)

UI.Label("Sonar alarma, mensaje de:")
addTextEdit("Sonar Alarma A:", storage.sonarAlarmaA or "Ponid", function(widget, text)    
	storage.sonarAlarmaA = text
end)

UI.Separator()

UI.Button("Pausar Botting", function()
  activarCavebot.setOff()
  TargetBot.setOff()
  CaveBot.setOff()
end)

UI.Button("Reanudar Botting", function()
  activarCavebot.setOn()
end)

UI.Separator()

local looting = Panels.Looting(caveTab) 

UI.Separator()