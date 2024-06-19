local drawing = require('ext.drawing')
local window = require('ext.window')
local spaces = require('hs.spaces')

local ipc = require("hs.ipc")
local os = require("ext.os")
local utils = require("ext.utils")
local layout = require('ext.layout')
-- local ax = require("hs._asm.axuielement")
-- hs.ax = ax

local ctrl = {"ctrl"}
local cmd = {"cmd"}
local alt = {"alt"}
local cmd_alt = {"cmd", "alt"}
local ctrl_alt = {"ctrl", "alt"}
local ctrl_cmd = {"ctrl", "cmd"}
local ctrl_alt_cmd = {"cmd", "alt", "ctrl"}
local shift_alt_cmd = {"shift", "alt", "cmd"}
local shift_cmd = {"shift", "cmd"}

--------------------------------------------------------------------------------
-- CONFIGURATIONS
--------------------------------------------------------------------------------
hs.window.animationDuration = 0.1

local function config()
  hs.openConsoleOnDockClick(true)
  hs.hotkey.bind(ctrl_alt_cmd, "R", function()
    hs.showError('Hammerspoon config reload triggered using CTRL+ALT+CMD+R')
    hs.reload()
  end)

  -- Install the cli to
  ipc.cliInstall()

  darkMode = false
  hs.chooser.globalCallback = function(chooser, eventName)
    if eventName == 'willOpen' then
      chooser:bgDark(darkMode)
    end
  end

  function isDarkMode()
    local isDark = os.isDarkMode()
    darkMode = isDark == 'true'
    return darkMode
  end

  function setDarkMode(trueOrFalse)
    darkMode = trueOrFalse == true
    os.setDarkMode(darkMode)
    return darkMode
  end

  hs.loadSpoon('SpoonInstall')
  spoon.SpoonInstall.use_syncinstall = true
  spoon.SpoonInstall:andUse('ClipboardTool', {
    loglevel = 'error'
  })
  -- spoon.SpoonInstall:andUse('UnsplashZ')
  spoon.SpoonInstall:andUse('WinWin')

  spoon.SpoonInstall:andUse('Emojis', {
    hotkeys = {toggle = {alt, "space"}}
  })

  spoon.ClipboardTool:start()

  hs.hotkey.bind(ctrl_alt, 'space', function()
    spoon.ClipboardTool:toggleClipboard()
  end)

  -- hs.grid.MARGINX   = 0
  -- hs.grid.MARGINY   = 0
  -- hs.grid.GRIDWIDTH   = 6
  -- hs.grid.GRIDHEIGHT  = 4
  -- hs.hotkey.bind(ctrl_alt, 'g', hs.grid.show)

  -- Fix the shifting audio balance issue caused by the bose headphones
  function fixAudioBalance() hs.audiodevice.defaultOutputDevice():setBalance(0.5) end
  hs.audiodevice.defaultOutputDevice():setBalance(0.5)
  hs.audioFixTimer = hs.timer.new(30, fixAudioBalance):start()

  local units = {
    right30       = { x = 0.70, y = 0.00, w = 0.30, h = 1.00 },
    right70       = { x = 0.30, y = 0.00, w = 0.70, h = 1.00 },
    left70        = { x = 0.00, y = 0.00, w = 0.70, h = 1.00 },
    left30        = { x = 0.00, y = 0.00, w = 0.30, h = 1.00 }
  }

  -- Window Move
  local lastop
  local lastoptime
  function withinTime()
    local now = hs.timer.absoluteTime()
    local diff = lastoptime and now - lastoptime
    lastoptime = now
    return diff and diff < 500000000
  end


  function getGoodFocusedWindow(nofull)
     local win = hs.window.focusedWindow()
     if not win or not win:isStandard() then return end
     if nofull and win:isFullScreen() then return end
     return win
  end

  function switchSpace(skip,dir)
     for i=1,skip do
        hs.eventtap.keyStroke({"ctrl","fn"},dir,0) -- "fn" is a bugfix!
     end
  end

  function moveWindowOneSpace (dir, switch)
    local win = getGoodFocusedWindow(true)
    if not win then return end

    local screen = win:screen()
    local uuid = screen:getUUID()
    local userSpaces = nil
    for k,v in pairs(spaces.allSpaces()) do
       userSpaces = v
       if k == uuid then break end
    end
    if not userSpaces then return end

    local thisSpace = spaces.windowSpaces(win) -- first space win appears on
    if not thisSpace then return else thisSpace = thisSpace[1] end
    local last = nil
    local skipSpaces = 0

    for _, spc in ipairs(userSpaces) do
      -- skippable space
      if spaces.spaceType(spc) ~= "user" then
        skipSpaces = skipSpaces + 1
      else
        if last and ((dir == "left" and spc == thisSpace) or (dir == "right" and last == thisSpace)) then
          local newSpace = (dir == "left" and last or spc)
          if switch then switchSpace(skipSpaces + 1, dir) end
          spaces.moveWindowToSpace(win, newSpace)
          return
        end
        -- Haven't found it yet...
        last = spc
        skipSpaces = 0
      end
    end

    -- No space found
    hs.osascript.applescript("beep")
  end


  hs.hotkey.bind(ctrl_alt_cmd, "up", function()
    local diff = withinTime()
    if diff and lastop == 'fullscreen' then
      spoon.WinWin:moveAndResize('shrink')
    else
      spoon.WinWin:moveAndResize('fullscreen')
    end
    lastop = 'fullscreen'
  end)

  hs.hotkey.bind(ctrl_alt, "right", function()
    local diff = withinTime()
    if diff and lastop == 'halfdown' then
      spoon.WinWin:moveAndResize('cornerSE')
    elseif diff and lastop == 'halfup' then
      spoon.WinWin:moveAndResize('cornerNE')
    elseif diff and lastop == 'halfright' then
      hs.window.focusedWindow():move(units.right30, nil, true)
    elseif diff and lastop == 'halfleft' then
      hs.window.focusedWindow():move(units.left70, nil, true)
    else
      spoon.WinWin:moveAndResize('halfright')
    end
    lastop = 'halfright'
  end)

  hs.hotkey.bind(ctrl_alt, "left", function()
    local diff = withinTime()
    if diff and lastop == 'halfdown' then
      spoon.WinWin:moveAndResize('cornerSW')
    elseif diff and lastop == 'halfup' then
      spoon.WinWin:moveAndResize('cornerNW')
    elseif diff and lastop == 'halfleft' then
      hs.window.focusedWindow():move(units.left30, nil, true)
    elseif diff and lastop == 'halfright' then
      hs.window.focusedWindow():move(units.right70, nil, true)
    else
      spoon.WinWin:moveAndResize('halfleft')
    end
    lastop = 'halfleft'
  end)

  hs.hotkey.bind(ctrl_alt, "up", function()
    local diff = withinTime()
    if diff and lastop == 'halfright' then
      spoon.WinWin:moveAndResize('cornerNE')
    elseif diff and lastop == 'halfleft' then
      spoon.WinWin:moveAndResize('cornerNW')
    else
      spoon.WinWin:moveAndResize('halfup')
    end
    lastop = 'halfup'
  end)

  hs.hotkey.bind(ctrl_alt, "down", function()
    local diff = withinTime()
    if diff and lastop == 'halfright' then
      spoon.WinWin:moveAndResize('cornerSE')
    elseif diff and lastop == 'halfleft' then
      spoon.WinWin:moveAndResize('cornerSW')
    else
      spoon.WinWin:moveAndResize('halfdown')
    end
    lastop = 'halfdown'
  end)

  hs.hotkey.bind(ctrl, 'left', function()
    window.goToNextSpace('left')
  end)

  hs.hotkey.bind(ctrl, 'right', function()
    window.goToNextSpace('right')
  end)

  hs.hotkey.bind(ctrl_cmd, 'left', function()
    moveWindowOneSpace('left', true)
  end)

  hs.hotkey.bind(ctrl_cmd, 'right', function()
    moveWindowOneSpace('right', true)
  end)

  hs.hotkey.bind(ctrl_alt_cmd, 'left', function()
    local win = hs.window.focusedWindow()
    local screen = window.nextScreen(win, 'west')
    win:moveToScreen(screen)
    win:focus()
  end)

  hs.hotkey.bind(ctrl_alt_cmd, 'right', function()
    local win = hs.window.focusedWindow()
    local screen = window.nextScreen(win, 'east')
    win:moveToScreen(screen)
    win:focus()
  end)

  hs.hotkey.bind(ctrl_alt, 'm', function()
    local current = hs.audiodevice.defaultInputDevice()
    if current:muted() then
      hs.audiodevice.defaultInputDevice():setInputMuted(false)
      drawing.bezel("Unmuted")
    else
      hs.audiodevice.defaultInputDevice():setInputMuted(true)
      drawing.bezel("Muted")
    end
  end)



  local battery = {
    percentage = hs.battery.percentage()
  }

  function watchBattery()
  	local currentPercentage = hs.battery.percentage()
    if
      currentPercentage < battery.percentage
      and (
        currentPercentage < 10
        or (currentPercentage < 30 and (currentPercentage % 5 == 0))
      )
    then
      hs.notify.new({
        alwaysPresent = true,
        title = 'Attention',
        subTitle = 'Battery Charge at ' .. currentPercentage .. '%'
      }):send()
    end
    battery.percentage = currentPercentage
  end

  hs.batteryWatcher = hs.battery.watcher.new(watchBattery)
  hs.batteryWatcher:start()

      end

  function clear() hs.console.clearConsole() end


  local function ActiveBorders(opts)
    -- flags: 0 for not dragging, 1 for dragging window, -1 for dragging but not window
    local dragging = 0
    local dragging_window = nil
    local dragging_window_frame = nil
    local dragging_events = 0

    local highlighter = window.highlightRect()
    local listenForWindowMove = hs.eventtap.new({hs.eventtap.event.types.leftMouseDragged}, function(e)
      if dragging == 0 then
        if dragging_window ~= nil then
          dragging_events = dragging_events + 1

          local frame = dragging_window:frame()
          if dragging_window_frame.x ~= frame.x or dragging_window_frame.y ~= frame.y then
            dragging = dragging + 1
          elseif dragging_events > 15 then
            dragging = -1
            dragging_window = nil
            dragging_window_frame = nil
          end
          return
        end

        local win = hs.window.focusedWindow()
        if win ~= nil then
          local frame = win:frame()
          dragging_window = win
          dragging_window_frame = frame
        end
      elseif dragging % 20 == 1  then
        local mousePos = hs.mouse.getRelativePosition()
        local screen = hs.mouse.getCurrentScreen()
        local screenFrame = screen:frame()
        local layoutName = layout.isAtBorder(mousePos, screenFrame, 20)
        if layoutName ~= nil then
          local layoutFrame = layout.getFrame(dragging_window, screen, layoutName)
          highlighter:setFrame(layoutFrame)
          highlighter:show()
        else
          highlighter:hide()
        end
      end
    end)

    local listenForWindowMoveEnd = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(e)
      if dragging == 1 then
        if dragging_window ~= nil then
          local mousePos = hs.mouse.getRelativePosition()
          local screen = hs.mouse.getCurrentScreen()
          local screenFrame = screen:frame()
          local layoutName = layout.isAtBorder(mousePos, screenFrame, 20)
          local frame = layout.getFrame(dragging_window, screen, layoutName)
          if frame ~= nil then
            dragging_window:setFrame(frame)
            dragging_window:moveToScreen(screen)
          end
        end
        highlighter:hide()
      end

      dragging = 0
      dragging_window = nil
      dragging_window_frame = nil
      dragging_events = 0
    end)

    return {
      -- Expose variables to prevent garbage collection
      windowMove = listenForWindowMove,
      windowMoveEnd = listenForWindowMoveEnd,

      start = function()
        listenForWindowMove:start()
        listenForWindowMoveEnd:start()
      end,
      stop = function()
        listenForWindowMove:stop()
        listenForWindowMoveEnd:stop()
        highlighter:hide()
      end
    }
  end


  hs.activeBorders = ActiveBorders()
  hs.activeBorders:start()
  -- function round(num) return math.floor(num + 0.5) end


  -- Autocomplete words
  local function deleteChars(count)
    for i = 1, count do
      hs.eventtap.event.newKeyEvent({}, 'delete', true):post()
    end
  end

  local function pasteWord(word)
    local lastEntry = hs.pasteboard.getContents()
    hs.pasteboard.setContents(word)
    hs.eventtap.event.newKeyEvent({'cmd'}, 'v', true):setProperty(42, 55510):post()
    hs.eventtap.event.newKeyEvent({'cmd'}, 'v', false):post()
    hs.timer.doAfter(0.1, function() hs.pasteboard.setContents(lastEntry) end)
  end

  local function pasteWordFn(word)
    return {
      fn = function()
        pasteWord(word)
        hs.eventtap.keyStrokes(' ')
      end
    }
  end

  local function replaceWithFn(charsToDelete, typeWord)
    return {
      fn = function()
        deleteChars(charsToDelete)
        hs.eventtap.keyStrokes(typeWord)
      end
    }
  end

  local words = {
    ['Fooo'] = pasteWordFn('ooooooooooooooooooooooooooooooooooo'),
    ['Loremt'] = {
      fn = function()
        deleteChars(1)
        hs.eventtap.keyStrokes(' ')
        pasteWord('ipsum dolor sit amet, consectetur adipiscing elit')
        hs.eventtap.keyStrokes(' ')
      end
    },
    ['Loremp'] = {
      fn = function()
        deleteChars(1)
        hs.eventtap.keyStrokes(' ')
        pasteWord('ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae lobortis ante. Vivamus metus magna, fringilla vel euismod id, interdum ultricies metus.')
        hs.eventtap.keyStrokes(' ')
      end
    },
    ['Lorem '] = pasteWordFn('ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae lobortis ante. Vivamus metus magna, fringilla vel euismod id, interdum ultricies metus. Duis iaculis, ex et eleifend lacinia, magna augue ullamcorper mi, sit amet gravida mauris metus vel ex. Proin ut tellus eget sem mollis mattis non tincidunt orci. Aliquam imperdiet quam vel mi vehicula viverra. Curabitur commodo pellentesque risus, et tristique mi cursus eu. Vestibulum commodo laoreet posuere. Vestibulum aliquet sed lacus sit amet semper. Etiam molestie nunc odio, a sodales sem dictum a. Nam consectetur dapibus urna, vitae dignissim arcu cursus ac. Etiam at diam cursus, venenatis leo nec, dignissim mauris. Morbi nec massa nec dolor consequat varius id ut libero. Sed magna justo, bibendum et nunc eleifend, tempus lacinia ligula. Nam odio diam, ullamcorper et massa a, suscipit interdum nunc.'),
    [':+1:'] = replaceWithFn(4, '👍'),
    [':-1:'] = replaceWithFn(4, '👎'),
    [':smile:'] = replaceWithFn(2, '😃'),
    [':)'] = replaceWithFn(2, '😃'),
    [':D'] = replaceWithFn(2, '😆'),
    [':P'] = replaceWithFn(2, '😝'),
    [':grin:'] = replaceWithFn(6, '😁'),
    [':kiss:'] = replaceWithFn(6, '😘'),
    [':kissing:'] = replaceWithFn(9, '😚'),
    [':hug:'] = replaceWithFn(5, '🤗'),
    [':heart:'] = replaceWithFn(7, '❤️'),
    [':inlove:'] = replaceWithFn(8, '🥰')
  }

  local wordTree = {}

  for word in pairs(words) do
    local tree = wordTree
    local lastchar = nil
    for i = 1, #word do
      lastchar = word:sub(i, i)
      if i == #word then
        tree[lastchar] = tree[lastchar] or {}
        local actions = tree[lastchar].actions or {}
        actions[#actions + 1] = word
        tree[lastchar].actions = actions
      else
        tree[lastchar] = tree[lastchar] or {}
        tree = tree[lastchar]
      end
    end
  end

  -- print(hs.inspect(wordTree))

  local currentTrees = {}

  local function cloneTable(table)
    local copy = {}
    for key, value in pairs(table) do
      copy[key] = value
    end
    return copy
  end

  local function hasElements(table)
    for key, value in pairs(table) do
      return true
    end
    return false
  end

  keyPressWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    if event:getProperty(42) == 55510 then return end

    local char = event:getCharacters()
    for i,tree in ipairs(currentTrees) do
      local match = tree[char]
      if match ~= nil then
        print('Tree match', char)
        if match.actions ~= nil then
          for j = 1, #match.actions do
            local action = match.actions[j]
            print('Tree match action', char, action)
            local definition = words[action]
            if definition.fn ~= nil then definition.fn() end
          end
          match = cloneTable(match)
          match.actions = nil
          if hasElements(match) then
            currentTrees[i] = match
          else
            currentTrees[i] = nil
          end
        else
          print('Tree updated', char)
          currentTrees[i] = match
        end
      else
        print('Tree discarded', char)
        currentTrees[i] = nil
      end
    end

    local newMatch = wordTree[char]
    if newMatch ~= nil then
      print('New Tree Match', char)
      currentTrees[#currentTrees + 1] = newMatch
    end

    return false
  end)

  -- keyPressWatcher:start()
end

config()


