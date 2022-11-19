local Event       = require "necro.event.Event"
local GameSession = require "necro.client.GameSession"
local Menu        = require "necro.menu.Menu"

local KeyBank = require "SaveEditor.i18n.KeyBank"

local announce = true

local function exitAndRefresh()
  Menu.close()
  if GameSession.getCurrentModeID() == "Lobby" then
    GameSession.restart()
  end
  announce = false
end

Event.menu.add("menuSaveEditor", "SaveEditor_editor", function(ev)
  local menu = {}
  local entries = {
    {
      id = "playableCharacter",
      label = KeyBank.PlayableCharacter,
      action = function() Menu.open("SaveEditor_playableCharacter") end
    },
    {
      id = "lobbyNPC",
      label = KeyBank.LobbyNPC,
      action = function() Menu.open("SaveEditor_lobbyNPC") end
    },
    {
      id = "itemGrantPermanent",
      label = KeyBank.ItemGrantPermanent,
      action = function() Menu.open("SaveEditor_itemGrantPermanent") end
    },
    {
      id = "itemPool",
      label = KeyBank.ItemPool,
      action = function() Menu.open("SaveEditor_itemPool") end
    },
    {
      id = "enemyTraining",
      label = KeyBank.EnemyTraining,
      action = function() Menu.open("SaveEditor_enemyTraining") end
    },
    {
      id = "itemUsed",
      label = KeyBank.ItemUsed,
      action = function() Menu.open("SaveEditor_itemUsed") end
    },
    {
      id = "extraMode",
      label = KeyBank.ExtraModes,
      action = function() Menu.open("SaveEditor_extraMode") end
    },
    {
      height = 0
    },
    {
      id = "_done",
      label = L("Close and restart lobby", "restartLobby"),
      action = exitAndRefresh
    }
  }

  menu.entries = entries
  menu.label = L("Save Editor", "saveEditorTitle")
  menu.escapeAction = exitAndRefresh
  ev.menu = menu
end)

Event.progressionUnlock.override("showCharacterUnlockAnnouncement", 1, function(func, ev)
  if announce then func(ev) end
  announce = true
end)
