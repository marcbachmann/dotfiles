local module = {}

module.layouts = {
  full = hs.geometry.rect(0, 0, 1, 1),
  north = hs.geometry.rect(0, 0, 1, .5),
  south = hs.geometry.rect(0, .5, 1, .5),
  west = hs.geometry.rect(0, 0, .5, 1),
  east = hs.geometry.rect(.5, 0, .5, 1),
  northWest = hs.geometry.rect(0, 0, .5, .5),
  northEast = hs.geometry.rect(.5, 0, .5, .5),
  southWest = hs.geometry.rect(0, .5, .5, .5),
  southEast = hs.geometry.rect(.5, .5, .5, .5)
}

module.getFrame = function(win, screen, layoutName)
  local layout = module.layouts[layoutName]
  if layout == nil then return end

  local frame = win:frame()
  local screenFrame = screen:frame()
  frame.x = screenFrame.x + (screenFrame.w * layout.x)
  frame.y = screenFrame.y + (screenFrame.h * layout.y)
  frame.w = screenFrame.w * layout.w
  frame.h = screenFrame.h * layout.h
  return frame
end

module.isAtBorder = function(mousePos, screenFrame, bufferZone)
  if mousePos.y < bufferZone then -- touching top
    if mousePos.x < screenFrame.w * .2 then
      return 'northWest'
    elseif mousePos.x > screenFrame.w * .8 then
      return 'northEast'
    else
      return 'full'
    end
  elseif mousePos.x < bufferZone then -- touching left
    if mousePos.y < screenFrame.h * .2 then
      return 'northWest'
    elseif mousePos.y > screenFrame.h * .8 then
      return 'southWest'
    else
      return 'west'
    end
  elseif mousePos.x > screenFrame.w - bufferZone then -- touching right
    if mousePos.y < screenFrame.h * .2 then
      return 'northEast'
    elseif mousePos.y > screenFrame.h * .8 then
      return 'southEast'
    else
      return 'east'
    end
  elseif mousePos.y > screenFrame.h - bufferZone then -- bottom
    if mousePos.x < screenFrame.w * .2 then
      return 'southWest'
    elseif mousePos.x > screenFrame.w * .8 then
      return 'southEast'
    else
      return 'full'
    end
  end

  return nil
end

return module
