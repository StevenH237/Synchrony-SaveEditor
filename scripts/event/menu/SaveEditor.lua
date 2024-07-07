local Event       = require "necro.event.Event"
local GameSession = require "necro.client.GameSession"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"

local Text = require "SaveEditor.i18n.Text"

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
      label = Text.PlayableCharacter,
      action = function() Menu.open("SaveEditor_playableCharacter") end
    },
    {
      id = "lobbyNPC",
      label = Text.LobbyNPC,
      action = function() Menu.open("SaveEditor_lobbyNPC") end
    },
    {
      id = "itemGrantPermanent",
      label = Text.ItemGrantPermanent,
      action = function() Menu.open("SaveEditor_itemGrantPermanent") end
    },
    {
      id = "itemPool",
      label = Text.ItemPool,
      action = function() Menu.open("SaveEditor_itemPool") end
    },
    {
      id = "enemyTraining",
      label = Text.EnemyTraining,
      action = function() Menu.open("SaveEditor_enemyTraining") end
    },
    {
      id = "itemUsed",
      label = Text.ItemUsed,
      action = function() Menu.open("SaveEditor_itemUsed") end
    },
    {
      id = "extraMode",
      label = Text.ExtraModes,
      action = function() Menu.open("SaveEditor_extraMode") end
    },
    {
      height = 0
    },
    -- {
    --   id = "debug",
    --   label = Text.Debug,
    --   action = function()
    --     for k, v in pairs(Progression.UnlockType) do
    --       print(Progression.getAllUnlocks(v))
    --     end
    --   end
    -- },
    -- {
    --   height = 0
    -- },
    {
      id = "_done",
      label = L("Close and restart lobby", "restartLobby"),
      action = exitAndRefresh
    }
  }

  menu.entries = entries
  menu.label = Text.SaveEditor
  menu.escapeAction = exitAndRefresh
  ev.menu = menu
end)

Event.progressionUnlock.override("showCharacterUnlockAnnouncement", 1, function(func, ev)
  if announce then func(ev) end
  announce = true
end)
