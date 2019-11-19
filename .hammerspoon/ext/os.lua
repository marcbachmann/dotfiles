local module = {}

-- returns 'true' or 'false'
module.isDarkMode = function()
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell appearance preferences
        return dark mode as string
      end tell
    end tell
  ]])

  return res
end

module.toggleDarkMode = function()
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell appearance preferences
        set dark mode to not dark mode
        return dark mode as string
      end tell
    end tell
  ]])

  return res
end

module.setDarkMode = function(_appearance)
  local darkMode = _appearance == true
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell appearance preferences
        set dark mode to ]] .. tostring(darkMode) .. [[ 
        return dark mode as string
      end tell
    end tell
  ]])

  return res
end

module.flashScreen = function()
  hs.applescript.applescript('beep')
end

return module
