-- main tab
VERSION = "1.0.0"

UI.Label("Config version: " .. VERSION)

UI.Separator()

-- Locals
local cigarroId = 141
local wand8k = {}
local wand3k = {"Green Demon", "Xerxes", "Virus de Influenza", "Oso Polar", "Yeti Chan", "Bato Infectado", "Teibolera Infectada", "Perro con Sida"}


local target

macro(10, "Fast Attack", "", function()
    if g_game.isAttacking() and not target then
        target = g_game.getAttackingCreature()
    end

    if target and g_game.isAttacking() and getDistanceBetween(pos(), target:getPosition()) <= 8 and not isInPz() then
        local atk = OutputMessage.create()
        local protocol = g_game.getProtocolGame()
        local id = target:getId()
        atk:addU8(161)
        atk:addU32(id)
        for i = 10, 1, -1 do
            if i > 1 then
                protocol:send(atk)
            end
        end
    end

    if not g_game.isAttacking() and target ~= nil then
        target = nil
    end
end)

onCreatureDisappear(function(creature)
    if target then
        if creature:getId() == target:getId() then
            target = nil
        end
    end
end)

macro(50, "Auto Cigarro", "", function()
  local skull = skull()
  if skull >= 4 then
      use(cigarroId)
  end
end)

UI.Separator()

UI.Button("Ingame macro editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_macros_main or "", {title="Macro editor", description="You can add your custom macros (or any other lua code) here"}, function(text)
    storage.ingame_macros_main = text
    reload()
  end)
end)

UI.Button("Ingame hotkey editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_hotkeys_main or "", {title="Hotkeys editor", description="You can add your custom hotkeys/singlehotkeys here"}, function(text)
    storage.ingame_hotkeys_main = text
    reload()
  end)
end)

UI.Separator()

for _, scripts in ipairs({storage.ingame_macros_main, storage.ingame_hotkeys_main}) do
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

UI.Label("HealRune Healing")
if type(storage.hpHeal) ~= "table" then
  storage.hpHeal = {on = false, title = "%HP", item = 3160, min = 90}
end

local hpHealMacro = macro(200, function()
  if (hppercent() <= storage.hpHeal.min) then
    usewith(storage.hpHeal.item, player) 
end
end)
hpHealMacro.setOn(storage.hpHeal.on)

UI.SingleScrollItemPanel(storage.hpHeal, function(widget, newParams) 
  storage.hpHeal = newParams
  hpHealMacro.setOn(storage.hpHeal.on)
end)

UI.Separator()

UI.Label("ManaRune Healing")
if type(storage.manaHeal) ~= "table" then
  storage.manaHeal = {on = false, title = "%MP", item = 3182, min = 90}
end

local manaHealMacro = macro(200, function()
  if (manapercent() <= storage.manaHeal.min) then
    usewith(storage.manaHeal.item, player) 
end
end)
manaHealMacro.setOn(storage.manaHeal.on)

UI.SingleScrollItemPanel(storage.manaHeal, function(widget, newParams) 
  storage.manaHeal = newParams
  manaHealMacro.setOn(storage.manaHeal.on)
end)

UI.Separator()

UI.Label("Paladin Inmortal")

if type(storage.rpInmortal) ~= "table" then
	storage.rpInmortal = {on = false, title = "Paladin Inmortal", item1 = 406, item2 = 3097, slot = 9}
end

local rpInmorltalMacro = macro(100, function()
	local lifeLessThan = tonumber(storage.anilloEnVida)
	local lifeMoreThan = tonumber(storage.anilloEnQuitarVida)
	local slotItem = getSlot(storage.rpInmortal.slot)
	local itemOne = findItem(storage.rpInmortal.item1)
	local itemTwo = findItem(storage.rpInmortal.item2)

	if hppercent() <= lifeLessThan then
		if not slotItem then
			if not itemOne then return end
			g_game.move(itemOne, {x = 65535, y = storage.rpInmortal.slot, z = 0}, itemOne:getCount())
			return
		end

		if slotItem:getId() ~= storage.manoCambiada.item1 then
			if not itemOne then return end
			g_game.move(itemOne, {x = 65535, y = storage.rpInmortal.slot, z = 0}, itemOne:getCount())
		end
		return
	elseif hppercent() >= lifeMoreThan then
		if storage.rpInmortal.item2 ~= 0 and itemTwo and slotItem then
			if slotItem:getId() ~= storage.manoCambiada.item2 then
				g_game.move(itemTwo, {x = 65535, y = storage.rpInmortal.slot, z = 0}, itemTwo:getCount())
				return
			end
		end
		if storage.rpInmortal.item2 == 0 then
			g_game.move(getInventoryItem(9), {x = 65535, y = 3, z = 0})
		end
	end

	if not slotItem or slotItem == nil and storage.rpInmortal.item2 ~= 0 then
		if not itemTwo then return end
		g_game.move(itemTwo, {x = 65535, y = storage.rpInmortal.slot, z = 0}, itemTwo:getCount())
	end
end)
rpInmorltalMacro.setOn(storage.rpInmortal.on)

UI.TwoItemsAndSlotPanel(storage.rpInmortal, function(widget, newParams) 
	storage.rpInmortal = newParams
	rpInmorltalMacro.setOn(storage.rpInmortal.on)
end)

UI.Label("Poner Utamo xHP%:")
addTextEdit("anilloEnVida", storage.anilloEnVida or "30", function(widget, text)
	storage.anilloEnVida = text
end)

UI.Label("Quitar Utamo xHP%:")
addTextEdit("anilloEnQuitarVida", storage.anilloEnQuitarVida or "90", function(widget, text)
	storage.anilloEnQuitarVida = text
end)

UI.Separator()

macro(200, "RangeAttack Spell", "F12", function()
  local target = g_game.getAttackingCreature()
  if target and getDistanceBetween(pos(), target:getPosition()) <= 8 then
      say(storage.autoAttackSpellSingle)
  end
end)

UI.Label("Spell a Lanzar:")
addTextEdit("autoAttackSpellSingle", storage.autoAttackSpellSingle or "exevo slasky san", function(widget, text)    
    storage.autoAttackSpellSingle = text
end)

UI.Separator()

local reuseItems = {3151, 16344, 3194, 3192}
local reUseToggle = macro(1000, "Click ReUse", function() end)

onUseWith(function(pos, itemId, target, subType)
	if reUseToggle.isOn() then
		if table.find(reuseItems, itemId) then
			schedule(50, function()
				local item = Item.create(itemId)
				if item then
					modules.game_interface.startUseWith(item)
				end
			end)
		end
	end
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

UI.Button("Buscar Personaje", function()
  g_platform.openUrl("http://armada-azteca.com/azteca/player/")
end)

UI.Button("Armada Face", function()
  g_platform.openUrl("https://www.facebook.com/armadaazteca/")
end)

UI.Separator()