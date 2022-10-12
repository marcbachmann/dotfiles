local module = {}

-- -- returns 'true' or 'false'
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

module.setDarkMode = function(appearance)
  if appearance == true then
    hs.applescript.applescript([[
      tell application "System Events"
        tell appearance preferences
          set dark mode to true
        end tell
      end tell
    ]])
  else
    hs.applescript.applescript([[
      tell application "System Events"
        tell appearance preferences
          set dark mode to false
        end tell
      end tell
    ]])
  end

  module.writeDarkmodeFile(appearance)
  return res
end

module.flashScreen = function()
  hs.applescript.applescript('beep')
end

module.writeDarkmodeFile = function(appearance)
  file = io.open(os.getenv("HOME") .. "/.darkmode", "w")
  if appearance == true then
    file:write('dark')
  else
    file:write('light')
  end
  file:close()
end

return module
