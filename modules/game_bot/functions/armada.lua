local context = G.botContext
if type(context.UI) ~= "table" then
  context.UI = {}
end
local UI = context.UI

UI.SingleScrollItemPanel = function(params, callback, parent) -- callback = function(widget, newParams)
    --[[ params:
      on - bool,
      item - number,
      subType - number,
      title - string,
      min - number,
      max - number,
    ]]
    params.title = params.title or "title"
    params.item = params.item or 0
    params.subType = params.subType or 0
    params.min = params.min or 20
    
    local widget = UI.createWidget('SingleScrollItemPanel', parent)
  
    widget.title:setOn(params.on)
    widget.title.onClick = function()
      params.on = not params.on
      widget.title:setOn(params.on)
      if callback then
        callback(widget, params)
      end
    end
  
    widget.item:setItem(Item.create(params.item, params.subType))
    widget.item.onItemChange = function()
      params.item = widget.item:getItemId()
      params.subType = widget.item:getItemSubType()
      if callback then
        callback(widget, params)
      end
    end
    
    local update  = function(dontSignal)
      widget.title:setText(" ".. params.min .." ".. params.title .." ")  
      if callback and not dontSignal then
        callback(widget, params)
      end
    end
    
    widget.scroll:setValue(params.min)
  
    widget.scroll.onValueChange = function(scroll, value)
      params.min = value
      update()
    end
    update(true)
  end