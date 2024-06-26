--- === ClipboardTool ===
---
--- Keep a history of the clipboard for text entries and manage the entries with a context menu
---
--- Originally based on TextClipboardHistory.spoon by Diego Zamboni with additional functions provided by a context menu
--- and on [code by VFS](https://github.com/VFS/.hammerspoon/blob/master/tools/clipboard.lua), but with many changes and some contributions and inspiration from [asmagill](https://github.com/asmagill/hammerspoon-config/blob/master/utils/_menus/newClipper.lua).
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipboardTool.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipboardTool.spoon.zip)
local obj={}
obj.__index = obj

-- Metadata
obj.name = "ClipboardTool"
obj.version = "0.7"
obj.author = "Alfred Schilken <alfred@schilken.de>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local getSetting = function(label, default) return hs.settings.get(obj.name.."."..label) or default end
local setSetting = function(label, value)   hs.settings.set(obj.name.."."..label, value); return value end

--- ClipboardTool.frequency
--- Variable
--- Speed in seconds to check for clipboard changes. If you check too frequently, you will degrade performance, if you check sparsely you will loose copies. Defaults to 0.8.
obj.frequency = 0.8

--- ClipboardTool.hist_size
--- Variable
--- How many items to keep on history. Defaults to 100
obj.hist_size = 100

--- ClipboardTool.honor_ignoredidentifiers
--- Variable
--- If `true`, check the data identifiers set in the pasteboard and ignore entries which match those listed in `ClipboardTool.ignoredIdentifiers`. The list of identifiers comes from http://nspasteboard.org. Defaults to `true`
obj.honor_ignoredidentifiers = true

--- ClipboardTool.paste_on_select
--- Variable
--- Whether to auto-type the item when selecting it from the menu. Can be toggled on the fly from the chooser. Defaults to `false`.
obj.paste_on_select = getSetting('paste_on_select', false)

--- ClipboardTool.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('ClipboardTool')

--- ClipboardTool.ignoredIdentifiers
--- Variable
--- Types of clipboard entries to ignore, see http://nspasteboard.org. Code from https://github.com/asmagill/hammerspoon-config/blob/master/utils/_menus/newClipper.lua. Default value (don't modify unless you know what you are doing):
--- ```
---  {
---     ["de.petermaurer.TransientPasteboardType"] = true, -- Transient : Textpander, TextExpander, Butler
---     ["com.typeit4me.clipping"]                 = true, -- Transient : TypeIt4Me
---     ["Pasteboard generator type"]              = true, -- Transient : Typinator
---     ["com.agilebits.onepassword"]              = true, -- Confidential : 1Password
---     ["org.nspasteboard.TransientType"]         = true, -- Universal, Transient
---     ["org.nspasteboard.ConcealedType"]         = true, -- Universal, Concealed
---     ["org.nspasteboard.AutoGeneratedType"]     = true, -- Universal, Automatic
---  }
--- ```
obj.ignoredIdentifiers = {
   ["de.petermaurer.TransientPasteboardType"] = true, -- Transient : Textpander, TextExpander, Butler
   ["com.typeit4me.clipping"]                 = true, -- Transient : TypeIt4Me
   ["Pasteboard generator type"]              = true, -- Transient : Typinator
   ["com.agilebits.onepassword"]              = true, -- Confidential : 1Password
   ["org.nspasteboard.TransientType"]         = true, -- Universal, Transient
   ["org.nspasteboard.ConcealedType"]         = true, -- Universal, Concealed
   ["org.nspasteboard.AutoGeneratedType"]     = true, -- Universal, Automatic
}

--- ClipboardTool.deduplicate
--- Variable
--- Whether to remove duplicates from the list, keeping only the latest one. Defaults to `true`.
obj.deduplicate = true

--- ClipboardTool.show_in_menubar
--- Variable
--- Whether to show a menubar item to open the clipboard history. Defaults to `true`
obj.show_in_menubar = true

--- ClipboardTool.menubar_title
--- Variable
--- String to show in the menubar if `ClipboardTool.show_in_menubar` is `true`. Defaults to SF Symbols `list.clipboard`
obj.menubar_title   = "􀒖" -- "􁕜"

----------------------------------------------------------------------

-- Internal variable - Chooser/menu object
obj.selectorobj = nil
-- Internal variable - Cache for focused window to work around the current window losing focus after the chooser comes up
obj.prevFocusedWindow = nil
-- Internal variable - Timer object to look for pasteboard changes
obj.timer = nil

local pasteboard = require("hs.pasteboard") -- http://www.hammerspoon.org/docs/hs.pasteboard.html
local hashfn   = require("hs.hash").MD5

-- Keep track of last change counter
local last_change = nil;

--- ClipboardTool:togglePasteOnSelect()
--- Method
--- Toggle the value of `ClipboardTool.paste_on_select`
function obj:togglePasteOnSelect()
   self.paste_on_select = setSetting("paste_on_select", not self.paste_on_select)
end

-- Internal method - process the selected item from the chooser. An item may invoke special actions, defined in the `actions` variable.
function obj:_processSelectedItem(value)
   local actions = {
      none = function() end,
      clear = hs.fnutils.partial(self.clearAll, self),
      toggle_paste_on_select = hs.fnutils.partial(self.togglePasteOnSelect, self)
   }
   if self.prevFocusedWindow ~= nil then
      self.prevFocusedWindow:focus()
   end
   if value and type(value) == "table" then
      if value.action and actions[value.action] then
         actions[value.action](value)
      elseif value.type == 'text' then
        pasteboard.setContents(value.data)
        if (self.paste_on_select) then hs.eventtap.keyStroke({"cmd"}, "v") end
      elseif value.type == "image" then
        pasteboard.writeObjects(hs.image.imageFromURL(value.data))
        if (self.paste_on_select) then hs.eventtap.keyStroke({"cmd"}, "v") end
      end
      last_change = pasteboard.changeCount()
   end
end

--- ClipboardTool:clearAll()
--- Method
--- Clears the clipboard and history
function obj:clearAll()
   pasteboard.clearContents()
   obj.db:exec("DELETE FROM clipboard;")
   last_change = pasteboard.changeCount()
end

--- ClipboardTool:clearLastItem()
--- Method
--- Clears the last added to the history
function obj:clearLastItem()
   obj.db:exec("DELETE FROM clipboard WHERE id = (SELECT MAX(id) FROM clipboard);")
   last_change = pasteboard.changeCount()
end

function executeStatement(stmt, ...)
  stmt:bind_values(...)
  local t = {}
  for row in stmt:nrows() do table.insert(t, row) end
  stmt:reset()
  return t
end

--- ClipboardTool:pasteboardToClipboard('text|image', item)
--- Method
--- Add the given string to the history
---
--- Parameters:
---  * item - string to add to the clipboard history
---
--- Returns:
---  * None
function obj:pasteboardToClipboard(timestamp, itemType, content)
  self.logger.df("Set content = %s", hs.inspect(content))
  executeStatement(obj.dbInsertItem, hashfn(content), timestamp, itemType, content)
end

-- Internal method: actions of the context menu, delete or rearrange of clips
function obj:removeItem(row)
  executeStatement(obj.dbDeleteItem, row.id)
  self.selectorobj:refreshChoicesCallback()
end

-- Internal method:
function obj:_showContextMenu(index)
  local row = menuData[index]
  print("_showContextMenu row: " .. row.id)
  point = hs.mouse.getAbsolutePosition()
  local menu = hs.menubar.new(false)
  local menuTable = {
       { title = "Remove entry",   fn = hs.fnutils.partial(self.removeItem, self, row) }
   }
  menu:setMenu(menuTable)
  menu:popupMenu(point)
  print(hs.inspect(point))
end

obj.colorPalette = {
  light = {
    text = { red = 1, green = 1, blue = 1, alpha = 1.0 }
  },
  dark = {
    text = { red = 0.43, green = 0.43, blue = 0.43, alpha = 1.0 }
  }
}

function obj:__sfSymbolToImage (symbol)
  local char = hs.styledtext.new(symbol, {
    font = { name = "SF Pro", size = 12},
    color = obj.colorPalette.dark.text
  })

  local canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 })
  local size = canvas:minimumTextSize(char)
  size.h = size.h + 6
  size.w = size.w + 6
  canvas:canvasDefaultFor("padding", 3)
  canvas:size(size)
  canvas[#canvas + 1] = {type = 'text', text = char}
  local image = canvas:imageFromCanvas()
  canvas:delete()
  return image
end

-- Internal function - fill in the chooser options, including the control options
function obj:_populateChooser()
  menuData = {}
  for k,v in pairs(executeStatement(obj.dbSelectItems)) do
    if (v.type == 'text') then
      table.insert(menuData, {
        id = v.id,
        type = v.type,
        text = self:_firstLines(v.content),
        data = v.content,
        image = self:__sfSymbolToImage('􀅯') -- textformat.abc
      })
    elseif (v.type == "image") then
      table.insert(menuData, {
        id = v.id,
        type = v.type,
        text = "《 Image data 》",
        data = v.content,
        image = hs.image.imageFromURL(v.content)
      })
    end
  end

  if #menuData == 0 then
    -- self.selectorobj:placeholderText('Clipboard is empty')
    table.insert(menuData, {
      text="Clipboard is empty",
      action = 'none',
      image = self:__sfSymbolToImage('􀟹') -- clipboard
    })
  else
    table.insert(menuData, {
      text="Clear Clipboard History",
      action = 'clear',
      image = self:__sfSymbolToImage('􀈑') -- trash
    })
  end

  -- table.insert(menuData, {
  --   text="《 " .. (self.paste_on_select and "Disable" or "Enable") .. " Paste-on-select 》",
  --   action = 'toggle_paste_on_select',
  --   image = (
  --     self.paste_on_select and self:__sfSymbolToImage('􀇯') -- rays
  --     or
  --     self:__sfSymbolToImage('􀍱') -- wand.and.rays
  --   )
  -- })

  self.logger.df("Returning menuData = %s", hs.inspect(menuData))
  return menuData
end

--- ClipboardTool:shouldBeStored()
--- Method
--- Verify whether the pasteboard contents matches one of the values in `ClipboardTool.ignoredIdentifiers`
function obj:shouldBeStored()
  -- Code from https://github.com/asmagill/hammerspoon-config/blob/master/utils/_menus/newClipper.lua
  for i,v in ipairs(hs.pasteboard.pasteboardTypes()) do
    if self.ignoredIdentifiers[v] then
      return false
    end
  end

  for i,v in ipairs(hs.pasteboard.contentTypes()) do
    if self.ignoredIdentifiers[v] then
      return false
    end
  end

  return true
end

function obj:_firstLines (content)
  local lines = {}
  for line in content:gmatch("([^\n]*)\n?") do
    lines[#lines + 1] = line
    if #lines == 3 then break end
  end

  return table.concat(lines, "\n")
end

--- ClipboardTool:checkAndStorePasteboard()
--- Method
--- If the pasteboard has changed, we add the current item to our history and update the counter
function obj:checkAndStorePasteboard()
   now = pasteboard.changeCount()
   if (now > last_change) then
      if (not self.honor_ignoredidentifiers) or self:shouldBeStored() then
         current_clipboard = pasteboard.getContents()
         self.logger.df("current_clipboard = %s", tostring(current_clipboard))
         if (current_clipboard == nil) and (pasteboard.readImage() ~= nil) then
            current_clipboard = pasteboard.readImage()
            self:pasteboardToClipboard(now, "image", current_clipboard:encodeAsURLString())
            self.logger.df("Adding image (hashed) %s to clipboard history clipboard", hashfn(current_clipboard:encodeAsURLString()))
         elseif current_clipboard ~= nil then
           local size = #current_clipboard
            self.logger.df("Adding %s to clipboard history", current_clipboard)
            self:pasteboardToClipboard(now, 'text', current_clipboard)
         else
            self.logger.df("Ignoring nil clipboard content")
         end
      else
         self.logger.df("Ignoring pasteboard entry because it matches ignoredIdentifiers")
      end
      last_change = now
   end
end

--- ClipboardTool:start()
--- Method
--- Start the clipboard history collector
function obj:start()
   obj.db = hs.sqlite3.open('./clipboard.sqlite')
   obj.db:exec("CREATE TABLE IF NOT EXISTS clipboard (id INTEGER PRIMARY KEY, timestamp INTEGER, hash TEXT, type TEXT, content TEXT);")
   obj.db:exec("CREATE INDEX clipboard_idx_timestamp ON clipboard(timestamp);")
   obj.db:exec("CREATE UNIQUE INDEX clipboard_idx_hash_unique ON clipboard(hash);")
  --  obj.db:exec("CREATE VIRTUAL TABLE email USING fts5(sender, title, body);")
   obj.dbInsertItem = obj.db:prepare("INSERT INTO clipboard (hash, timestamp, type, content) VALUES (?, ?, ?, ?) ON CONFLICT DO UPDATE SET timestamp = EXCLUDED.timestamp;")
   obj.dbDeleteItem = obj.db:prepare("DELETE FROM clipboard WHERE id = ?;")
   obj.dbSelectItems = obj.db:prepare("SELECT * FROM clipboard ORDER BY timestamp DESC LIMIT 100;")

   last_change = pasteboard.changeCount() -- keeps track of how many times the pasteboard owner has changed // Indicates a new copy has been made
   self.selectorobj = hs.chooser.new(hs.fnutils.partial(self._processSelectedItem, self))
   self.selectorobj:choices(hs.fnutils.partial(self._populateChooser, self))
   self.selectorobj:rightClickCallback(hs.fnutils.partial(self._showContextMenu, self))
   --Checks for changes on the pasteboard. Is it possible to replace with eventtap?
   self.timer = hs.timer.new(self.frequency, hs.fnutils.partial(self.checkAndStorePasteboard, self))
   self.timer:start()
   if self.show_in_menubar then
      self.menubaritem = hs.menubar.new()
         :setTitle(obj.menubar_title)
         :setClickCallback(hs.fnutils.partial(self.toggleClipboard, self))
   end
end

--- ClipboardTool:showClipboard()
--- Method
--- Display the current clipboard list in a chooser
function obj:showClipboard()
  if self.selectorobj ~= nil then
    self.selectorobj:refreshChoicesCallback()
    self.prevFocusedWindow = hs.window.focusedWindow()
    self.selectorobj:show()
  else
    hs.notify.show("ClipboardTool not properly initialized", "Did you call ClipboardTool:start()?", "")
  end
end

--- ClipboardTool:toggleClipboard()
--- Method
--- Show/hide the clipboard list, depending on its current state
function obj:toggleClipboard()
  if self.selectorobj:isVisible() then
    self.selectorobj:hide()
  else
    self:showClipboard()
  end
end

--- ClipboardTool:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for ClipboardTool
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * show_clipboard - Display the clipboard history chooser
---   * toggle_clipboard - Show/hide the clipboard history chooser
function obj:bindHotkeys(mapping)
   local def = {
      show_clipboard = hs.fnutils.partial(self.showClipboard, self),
      toggle_clipboard = hs.fnutils.partial(self.toggleClipboard, self),
   }
   hs.spoons.bindHotkeysToSpec(def, mapping)
   obj.mapping = mapping
end

return obj

