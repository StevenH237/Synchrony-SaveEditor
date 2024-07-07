local Event        = require "necro.event.Event"
local Menu         = require "necro.menu.Menu"
local GameSession  = require "necro.client.GameSession"
local SinglePlayer = require "necro.client.SinglePlayer"

local Text = require "SaveEditor.i18n.Text"

Event.menu.override("pause", 1, function(func, ev)
  -- Run regular menu event first
  func(ev)

  -- Ensure we're in singleplayer lobby
  -- Cancel this handler if not
  if not (GameSession.getCurrentModeID() == "Lobby" and SinglePlayer.isActive()) then
    return
  end

  -- Determine position of customize button
  local customize = 0

  for i, v in ipairs(ev.menu.entries) do
    if v.id == "customize" then
      customize = i
      break
    end
  end

  -- Add save editor entry
  table.insert(ev.menu.entries, customize + 1, {
    id = "debug",
    label = Text.SaveEditor,
    action = function()
      Menu.open("SaveEditor_editor")
    end,
  })
end)
