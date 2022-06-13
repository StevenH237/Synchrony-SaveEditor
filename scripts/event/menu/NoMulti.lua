local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local StringUtils = require "system.utils.StringUtilities"

local MenuWarningText = StringUtils.split(
  L("Nixill's Synchrony Save Editor doesn't work in online\
multiplayer. To use the save editor, please first close\
the server. When you're finished, you may reopen the\
server and your changes will be in effect.", "menuWarningText"), "\n")

Event.menu.add("menuNoMulti", "SaveEditor_noMulti", function(ev)
  ev.menu = {}
  ev.menu.entries = {}

  if #MenuWarningText > 8 then
    ev.menu.entries[1] = {
      id = "_scrollDown",
      label = L("(Scroll down)", "scrollDown"),
      action = function() Menu.selectByID("_exit") end
    }
  end

  for i, text in ipairs(MenuWarningText) do
    ev.menu.entries[#ev.menu.entries + 1] = {
      id = "_label" .. i,
      label = text
    }
  end

  ev.menu.entries[#ev.menu.entries + 1] = {
    height = 0
  }

  ev.menu.entries[#ev.menu.entries + 1] = {
    id = "_exit",
    label = L("Exit", "exit"),
    action = Menu.close
  }
end)
