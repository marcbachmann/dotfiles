local drawing = require('ext.drawing')
local window = require('ext.window')
local ipc = require("hs.ipc")
local os = require("ext.os")
local utils = require("ext.utils")
local layout = require('ext.layout')

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
    local isDark = os.setDarkMode(trueOrFalse)
    darkMode = isDark == 'true'
    return darkMode
  end

  function toggleDarkMode()
    local isDark = os.toggleDarkMode()
    darkMode = isDark == 'true'
    return darkMode
  end

  hs.loadSpoon('SpoonInstall')
  spoon.SpoonInstall:andUse('UnsplashZ')
  spoon.SpoonInstall:andUse('WinWin')

  spoon.SpoonInstall:andUse('Emojis', {
    hotkeys = {toggle = {alt, "space"}}
  })

  hs.grid.MARGINX   = 0
  hs.grid.MARGINY   = 0
  hs.grid.GRIDWIDTH   = 6
  hs.grid.GRIDHEIGHT  = 4
  hs.hotkey.bind(ctrl_alt, 'g', hs.grid.show)

  -- Window Move
  local lastop
  local lastoptime
  function withinTime()
    local now = hs.timer.absoluteTime()
    local diff = lastoptime and now - lastoptime
    lastoptime = now
    return diff and diff < 500000000
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

  hs.hotkey.bind(ctrl_alt, "h", function()
    hs.hints.windowHints()
  end)

  hs.hotkey.bind(ctrl_cmd, 'left', function()
    window.moveToNextSpace('left')
  end)

  hs.hotkey.bind(ctrl_cmd, 'right', function()
    window.moveToNextSpace('right')
  end)

  hs.hotkey.bind(shift_cmd, 'b', function()
    local win = hs.window.focusedWindow()
    win:sendToBack()
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

  -- local menu_bar = hs.menubar.new()
  -- local network = hs.network.configuration.open()
  -- menu_bar:setTitle(network:hostname())
  -- hs.timer.doAt("0:00","1m", function()
  --   menu_bar:setTitle(network:hostname())
  -- end)

  local sound
  function playsound()
    if sound ~= nil and sound:isPlaying() then
      sound:stop()
      sound = nil
    else
      -- local device = hs.sound:device(nil)
      sound = hs.sound.getByFile('./sounds/applause-' .. math.random(1,8) .. '.wav')
      sound:play()
    end
  end

  function postToApp (name, mod, key)
    local app = hs.application.get(name)
    if app ~= nil then
      hs.eventtap.event.newKeyEvent(mod, key, true):post(app)
      hs.eventtap.event.newKeyEvent(mod, key, false):post(app)
    end
  end

  local keyMapping = {
    {key = 'F1', systemKey = 'BRIGHTNESS_DOWN'},
    {key = 'F2', systemKey = 'BRIGHTNESS_UP'},
    {key = 'F3', ondown = playsound},
    -- {key = 'F3', systemKey = 'VIDMIRROR'},
    {key = 'F4', ondown = hs.grid.show, onrepeat = false},
    {key = 'F5', systemKey = 'ILLUMINATION_DOWN'},
    {key = 'F6', systemKey = 'ILLUMINATION_UP'},
    {key = 'F7', systemKey = 'PREVIOUS', onrepeat = false},
    {key = 'F8', systemKey = 'PLAY', onrepeat = false},
    {key = 'F9', systemKey = 'NEXT', onrepeat = false},
    {key = 'F10', systemKey = 'MUTE', onrepeat = false},
    {key = 'F11', systemKey = 'SOUND_DOWN'},
    {key = 'F12', systemKey = 'SOUND_UP'},
    {
      mod = ctrl,
      key = 'F11',
      ondown = function()
        postToApp('iTunes', cmd, 'down')
        postToApp('TIDAL', cmd, 'down')
        drawing.bezel('Volume down')
        return true
      end
    },
    {
      mod = ctrl,
      key = 'F12',
      ondown = function()
        postToApp('iTunes', cmd, 'up')
        postToApp('TIDAL', cmd, 'up')
        drawing.bezel('Volume up')
        return true
      end
    }
  }

  local setupHotKey = function(mapping)
    local ondown = function(evt)
      if mapping.systemKey ~= nil then
        hs.eventtap.event.newSystemKeyEvent(mapping.systemKey, true):post()
        return true
      elseif mapping.ondown ~= nil then
        return mapping.ondown(evt)
      else
        return true
      end
    end

    local onup = function(evt)
      if mapping.systemKey ~= nil then
        hs.eventtap.event.newSystemKeyEvent(mapping.systemKey, false):post()
        return true
      elseif mapping.onup ~= nil then
        return mapping.onup(evt)
      else
        return true
      end
    end

    local onrepeat = function(evt)
      if mapping.onrepeat == false then
        return true
      elseif mapping.onrepeat then
        return mapping.onrepeat(evt)
      else
        ondown(evt)
        onup(evt)
      end
    end

    mapping.hotkey = hs.hotkey.bind(mapping.mod or {}, mapping.key, ondown, onup, onrepeat)
  end

  local destroyHotKey = function(mapping)
    if mapping.hotkey ~= nil then
      mapping.hotkey:delete()
      mapping.hotkey = nil
    end
  end

  function setupKeyMapping()
    hs.fnutils.each(keyMapping, destroyHotKey)
    hs.fnutils.each(keyMapping, setupHotKey)
  end

  function destroyKeyMapping()
    hs.fnutils.each(keyMapping, destroyHotKey)
  end

  setupKeyMapping()


  local zoom_logo = hs.image.iconForFile("/Applications/zoom.us.app")
  local chrome_logo = hs.image.iconForFile("/Applications/Google Chrome.app")
  spoon.SpoonInstall:andUse("Seal", {
    hotkeys = {show = {ctrl_alt, "space"}},
    fn = function(s)
      s:loadPlugins({"apps", "calc", "useractions"})
      s.plugins.useractions.actions = {
        ["Hammerspoon docs webpage"] = {
          url = "http://hammerspoon.org/docs/",
          icon = hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon)
        },
        ["Zoom Standup"] = {
          url = "zoommtg://zoom.us/join?zc=0&confno=574406794",
          icon = zoom_logo
        },
        ["Zoom Sprint Start"] = {
          url = "zoommtg://zoom.us/join?zc=0&confno=200779523",
          icon = zoom_logo
        },
        ["Zoom Sprint Planning"] = {
          url = "zoommtg://zoom.us/join?zc=0&confno=304294471",
          icon = zoom_logo
        },
        ["Zoom Fortnightly"] = {
          url = "zoommtg://zoom.us/join?zc=0&confno=944230941",
          icon = zoom_logo
        },
        ["Zoom Retro"] = {
          url = "zoommtg://zoom.us/join?zc=0&confno=309127793",
          icon = zoom_logo
        },
        ["Start zoom Meeting"] = {
          url = "zoommtg://zoom.us/join?zc=0&confno=${query}",
          icon = zoom_logo,
          keyword = "zoom"
        },
        ["Translate using Leo"] = {
          url = "http://dict.leo.org/englisch-deutsch/${query}",
          icon = 'favicon',
          keyword = "leo"
        },
        ["Chrome Private"] = {
          fn = function()
            hs.execute('"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --profile-directory="Default" https://github.com&')
            drawing.bezel("MB Profile")
          end,
          icon = chrome_logo
        },
        ["Chrome Livingdocs"] = {
          fn = function()
            hs.execute('"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --profile-directory="Profile 3" https://github.com&')
            drawing.bezel("LI Profile")
          end,
          icon = chrome_logo
        },
        ["WIFI Password"] = {
          fn = function()
            keyPressWatcher:stop()
            local pass = hs.execute("/usr/bin/security find-generic-password -a `/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -n 's/^ *SSID: //p'` -w")
            print(pass)
            if pass ~= '' then drawing.bezel(pass) end
            keyPressWatcher:start()
          end
        },
        ["Disable Function Key Mapping"] = {
          fn = destroyKeyMapping
        },
        ["Enable Function Key Mapping"] = {
          fn = setupKeyMapping
        },
        ["Toggle Files on Desktop"] = {
          fn = function()
            local isVisible = hs.execute('defaults read com.apple.finder CreateDesktop')
            if string.find(isVisible, 'true') then
              hs.execute('defaults write com.apple.finder CreateDesktop false; killall Finder')
            else
              hs.execute('defaults write com.apple.finder CreateDesktop true; killall Finder')
            end
          end
        },
        ["Enable Dark Mode"] = {
          fn = function () setDarkMode(true) end
        },
        ["Disable Dark Mode"] = {
          fn = function () setDarkMode(false) end
        },
        ["Branch Protection Rules"] = {
          url = "https://github.com/livingdocsIO/livingdocs-server/settings/branch_protection_rules/152491",
          icon = chrome_logo
        },
        ["Toggle VPN"] = {
          fn = function ()
            hs.applescript.applescript([[
              tell application "System Events"
                tell current location of network preferences
                  set VPNService to service "IPVanish"
                  set isConnected to connected of current configuration of VPNService
                  if isConnected then
                    disconnect VPNService
                  else
                    connect VPNService
                  end if
                end tell
              end tell
            ]])
          end
        }
      }
      s:refreshAllCommands()
    end,
   start = true,
  })


  -- local appsToFix = {}
  -- appsToFix["Slack"] = true
  -- appsToFix["WhatsApp"] = true

  hs.myAppWatcher = hs.application.watcher.new(function(name, type, app)
    print(name, type)
    -- fix annoying behavior in osx where apps that
    -- don't have a window open, aren't focused when
    -- opening the app using the application switcher (cmd+tab)
    if  type == hs.application.watcher.activated then
      -- and appsToFix[name] ~= nil
      local screen = hs.mouse.getCurrentScreen()
      local win = app:focusedWindow()
      if win == nil then
        hs.application.open(app:bundleID())
        -- local win = app:focusedWindow()
        -- if win ~= nil then
	--  win:moveToScreen(screen)
	-- end
      -- else
      --  win:moveToScreen(screen)
      end
    end
  end)

  hs.myAppWatcher:start()

  function clear() hs.console.clearConsole() end


  local function ActiveBorders(opts)
    -- flag, 0 for not dragging, 1 for dragging window, -1 for dragging but not window
    local dragging = 0
    local dragging_window = nil
    local dragging_window_frame = nil
    local dragging_events = 0

    -------------------------------------------------------------------
    --Window snapping with mouse, Windows style (Cinch Alternative)
    -------------------------------------------------------------------
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
        local layoutName = layout.isAtBorder(mousePos, screenFrame, 100)
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
          local layoutName = layout.isAtBorder(mousePos, screenFrame, 100)
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






  -- -- Modal example
  -- -- ------
  local currentScreen = nil
  local currentWindows = nil

  local function arrange()
    if currentWindows == nil then return nil end

    if currentWindows[4] ~= nil then
      currentWindows[1]:moveToScreen(currentScreen)
      currentWindows[2]:moveToScreen(currentScreen)
      currentWindows[3]:moveToScreen(currentScreen)
      currentWindows[4]:moveToScreen(currentScreen)
      currentWindows[1]:moveToUnit('[0,0,50,50]')
      currentWindows[2]:moveToUnit('[0,50,50,100]')
      currentWindows[3]:moveToUnit('[50,0,100,50]')
      currentWindows[4]:moveToUnit('[50,50,100,100]')
    elseif currentWindows[3] ~= nil then
      currentWindows[1]:moveToScreen(currentScreen)
      currentWindows[2]:moveToScreen(currentScreen)
      currentWindows[3]:moveToScreen(currentScreen)
      currentWindows[1]:moveToUnit('[0,0,50,100]')
      currentWindows[2]:moveToUnit('[50,0,100,50]')
      currentWindows[3]:moveToUnit('[50,50,100,100]')
    elseif currentWindows[2] ~= nil then
      currentWindows[1]:moveToScreen(currentScreen)
      currentWindows[2]:moveToScreen(currentScreen)
      currentWindows[1]:moveToUnit('[0,0,50,100]')
      currentWindows[2]:moveToUnit('[50,0,100,100]')
    elseif currentWindows[1] ~= nil then
      currentWindows[1]:moveToScreen(currentScreen)
      currentWindows[1]:maximize()
    end
  end

  mouseDownEvent = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function(e)
    local win = window.getWindowUnderMouse()
    if win ~= nil then
      print(win:title())
      currentWindows[#currentWindows + 1] = win
    end
  end)

  flagsEvent = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
    local flags = e:getFlags()
    if flags.ctrl and flags.alt then
      currentScreen = hs.mouse.getCurrentScreen()
      currentWindows = {}
      mouseDownEvent:start()
    else
      mouseDownEvent:stop()
      arrange()
      currentScreen = nil
      currentWindows = nil
    end
  end)

  flagsEvent:start()

  local modal = hs.hotkey.modal.new(ctrl_cmd, 'm')
  function modal:entered()
    hs.alert.closeAll()
    hs.alert.show("Window manager", 999999)

    -- hs.hotkey.bind(ctrl_alt, 'm', function()
  end

  function modal:exited()
    hs.alert.closeAll()
  end

  modal:bind('','escape', function() modal:exit() end)
  modal:bind('','return', function() modal:exit() end)
  modal:bind('','space', function() modal:exit() end)
  modal:bind(alt,'space', function() modal:exit() end)


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
    return {fn = function() pasteWord(word) end}
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
        hs.eventtap.event.newKeyEvent({}, 'delete', true):post()
        pasteWord(' ipsum dolor sit amet, consectetur adipiscing elit')
      end
    },
    ['Loremp'] = {
      fn = function()
        hs.eventtap.event.newKeyEvent({}, 'delete', true):post()
        pasteWord(' ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae lobortis ante. Vivamus metus magna, fringilla vel euismod id, interdum ultricies metus.')
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
    [':heart:'] = replaceWithFn(7, '❤️')
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

  print(hs.inspect(wordTree))

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

  keyPressWatcher:start()

  -- Missing
  -- - Three finger down swipe -> horizontal split in iTerm
  -- - Three finger up swipe -> horizontal split in iTerm
  -- - Three finger left swipe -> vertical split in iTerm
  -- - Three finger right swipe -> vertical split in iTerm
end

config()
