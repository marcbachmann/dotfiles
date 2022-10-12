local module = {}
local spaces = require("hs._asm.undocumented.spaces")

local function firstElement(tbl)
  for i=1, #tbl, 1 do
    return tbl[i]
  end
end

local function nextElement(tbl, key, offset)
  for i=1, #tbl, 1 do
    if tbl[i] == key then
      return tbl[i + offset]
    end
  end
end

local function flashScreen()
  hs.applescript.applescript('beep')
end

module.goToNextSpace = function(direction)
  -- local nextSpace = module.getNextSpace(direction)
  -- if nextSpace == nil then return flashScreen() end

  if direction == 'left' then
    direction = 'o'
  else
    direction = 'p'
  end

  -- Change the Move left a space binding to shift+ctrl+o first
  hs.eventtap.event.newKeyEvent({'shift', 'ctrl'}, direction, true):post()
  hs.eventtap.event.newKeyEvent({'shift', 'ctrl'}, direction, false):post()
end

module.getNextSpace = function(direction)
  local offset = 1
  if direction == 'left' then offset = -1 end

  local win = hs.window.focusedWindow()
  local screenUUID = win:screen():spacesUUID()
  local currentSpace = firstElement(win:spaces())
  if currentSpace == nil then return end

  return nextElement(spaces.layout()[screenUUID], currentSpace, offset)
end

module.moveToNextSpace = function(direction)
  local win = hs.window.focusedWindow()
  local nextSpace = module.getNextSpace(direction)
  if nextSpace == nil then return flashScreen() end
  spaces.moveWindowToSpace(win:id(), nextSpace)
  module.goToNextSpace(direction)
end

module.getWindowUnderMouse = function()
   local pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
   local screen = hs.mouse.getCurrentScreen()
   return hs.fnutils.find(hs.window.orderedWindows(), function(w)
     return w:screen() == screen
      and w:isStandard()
      and (not w:isFullScreen())
      and pos:inside(w:frame())
   end)
end

module.nextScreen = function(win, direction)
  local current = win:screen()
  if direction == 'east' then
    local screen = current:toEast()
    if screen ~= nil then return screen end
  else
    local screen = current:toWest()
    if screen ~= nil then return screen end
  end

  local screens = hs.screen.allScreens()
  for i=2, #screens, 1 do
    if direction == 'east' then
      current = current:toWest()
    else
      current = current:toEast()
    end
  end

  return current
end

module.highlightRect = function(destination)
  if destination == nil then destination = {} end
  local borderColor = {["red"]=.5,["blue"]=.5,["green"]=.5,["alpha"]=1}
  local fillColor = {["red"]=.5,["blue"]=.5,["green"]=.5,["alpha"]=.2}
  local rect = hs.drawing.rectangle(destination)
  rect:setStrokeWidth(3)
  rect:setStrokeColor(borderColor)
  rect:setRoundedRectRadii(5.0, 5.0)
  rect:setStroke(true):setFill(true):setFillColor(fillColor)
  rect:setLevel("floating")
  -- rect:show()
  return rect
end


-- function setFrame(win, screen, layoutName)
--     local frame = getFrame(win, screen, layoutName)
--     if frame == nil then return end
--     win:setFrame(frame)
--     win:moveToScreen(screen)
-- end

-- function animateTo(an)
--   local f = an.rect:frame()
--   local newX = an.source.x + (an.vector.x / an.totalFrames * an.frame)
--   local newY = an.source.y + (an.vector.y / an.totalFrames * an.frame)
--   local newW = an.source.w + (an.sizeDiff.w / an.totalFrames * an.frame)
--   local newH = an.source.h + (an.sizeDiff.h / an.totalFrames * an.frame)

--   local moveTo = hs.geometry.rect(newX, newY, newW, newH)
--   an.rect:setFrame(moveTo)
-- end

-- local animationDuration = 0.2
-- local frameDuration = 0.015
-- function animateRect(rect, from, to, onEnd)
--   local anim = {}
--   anim.rect = rect
--   anim.source = from
--   anim.destination = to
--   anim.sizeDiff = hs.geometry.size(to.w - from.w, to.h - from.h)
--   anim.vector = {x = to.x - from.x, y = to.y - from.y}
--   anim.totalFrames = animationDuration / frameDuration
--   anim.frame = 0
--   anim.timer = hs.timer.new(frameDuration, function()
--     if anim.frame >= anim.totalFrames then
--       anim.timer:stop()
--       anim.rect:setFrame(to)
--     else
--       anim.frame = anim.frame + 1
--       animateTo(anim)
--     end
--   end)
--   anim.stop = hs.timer.doAfter(3, function()
--     anim.timer:stop()
--     anim.stop:stop()

--     local rect = anim.rect
--     rect:hide(0.2)
--     hs.timer.doAfter(0.5, function() rect:delete() end)
--     if onEnd ~= nil then onEnd(anim) end
--   end)

--   anim.timer:start()
--   return anim
-- end


-- local animation = nil
-- function cancelAnimation()
--   if animation ~= nil then animation.stop:fire() end
-- end

-- hs.hotkey.bind(shift_cmd, 'u', function()
--   if animation ~= nil then animation.stop:fire() end

--   local win = hs.window.focusedWindow()
--   if win == nil then return end

--   local source = win:frame()
--   local destination = hs.geometry.rect(100, 100, 50, 50)
--   return highlightWindowTarget(source, destination)
-- end)

-- function highlightWindowTarget(source, destination, onEnd)
--   local rect = module.highlightRect(source)
--   rect:show(0.2)
--   return animateRect(rect, source, destination, onEnd)
-- end


return module
