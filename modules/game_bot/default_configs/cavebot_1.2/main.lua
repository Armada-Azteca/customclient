-- main tab
VERSION = "1.2"

UI.Label("Config version: " .. VERSION)

UI.Separator()

--local atk = Panels.FastAttack()

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


UI.Label("Armada Macros")
dofile("/armada/default.lua")

UI.Separator()
UI.Label("Ingame Macros")

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
UI.Label("Links")

UI.Button("Discord", function()
  g_platform.openUrl("https://discord.gg/2Z8Xupw")
end)

UI.Button("Donaciones", function()
  g_platform.openUrl("http://armada-azteca.com/azteca/donaciones")
end)

UI.Button("Wiki", function()
  g_platform.openUrl("http://armada-azteca.com/wiki")
end)
