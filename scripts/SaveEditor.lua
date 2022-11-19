local CustomActions = require "necro.game.data.CustomActions"
local GameSession   = require "necro.client.GameSession"
local Menu          = require "necro.menu.Menu"
local SinglePlayer  = require "necro.client.SinglePlayer"

local function openMenu()
  if SinglePlayer.isActive() then
    Menu.open("SaveEditor_editor")
  else
    Menu.open("SaveEditor_noMulti")
  end
end

CustomActions.registerSystemAction {
  id = "openEditor",
  name = L("Open save editor", "saveEditorControl"),
  keyBinding = { "Ctrl + Y" },
  callback = openMenu,
  enableIf = function()
    return GameSession.getCurrentModeID() == "Lobby"
  end
}
