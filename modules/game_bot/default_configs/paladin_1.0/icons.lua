
addIcon("dancing", {outfit={mount=0,feet=0,legs=0,body=176,type=128,auxType=0,addons=3,head=48}, hotkey=nil, text="dance"}, macro(80, "", function()
  turn(0)
  schedule(20, function() turn(1) end)
  schedule(40, function() turn(2) end)
  schedule(60, function() turn(3) end)
end))

addIcon("Random Outfit", {outfit={mount=0,feet=math.random(0, 133),legs=math.random(0, 133),body=math.random(0, 133),type=128,auxType=0,addons=3,head=math.random(0, 133)}, hotkey=nil, text="ROut"}, macro(20, "", nil, function()
  local outfit = outfit() math.random(0, 133)
  outfit.head = math.random(0, 133)
  outfit.body = math.random(0, 133)
  outfit.legs = math.random(0, 133)
  outfit.feet = math.random(0, 133)
  --outfit.addons = math.random(0, 3)
  setOutfit(outfit);
end))
--[[ 

addIcon("ctrl", {outfit={mount=0,feet=10,legs=10,body=176,type=129,auxType=0,addons=3,head=48}, text="press ctrl to move icon"}, function(widget, enabled)
  if enabled then
    info("icon on")  
  else
    info("icon off")   
  end
end)

addIcon("mount", {outfit={mount=848,feet=10,legs=10,body=176,type=129,auxType=0,addons=3,head=48}}, function(widget, enabled)
  if enabled then
    info("icon mount on")  
  else
    info("icon mount off")   
  end
end)

addIcon("mount 2", {outfit={mount=849,feet=10,legs=10,body=176,type=140,auxType=0,addons=3,head=48}, switchable=false}, function(widget, enabled)
  info("icon mount 2 pressed")  
end)

addIcon("item", {item=3380, hotkey="", switchable=false}, function(widget, enabled)
  info("icon clicked")
end)

addIcon("item2", {item={id=3043, count=100}, switchable=true}, function(widget, enabled)
  info("icon 2 clicked")
end)

addIcon("text", {text="text\nonly\nicon", switchable=true}, function(widget, enabled)
  info("icon with text clicked")
end)
 ]]
