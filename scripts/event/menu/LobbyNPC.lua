local Entities    = require "system.game.Entities"
local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"
local TextFormat  = require "necro.config.i18n.TextFormat"

local ProgressionState = nil

local function getProgressionState()
  if ProgressionState == nil then
    ProgressionState = {}

    for _, entity in Entities.prototypesWithComponents({ "npcUnlockable" }) do
      ProgressionState[entity.name] = {
        state = Progression.isUnlocked(Progression.UnlockType.LOBBY_NPC, entity.name),
        name = entity.friendlyName.name
      }
    end
  end

  return ProgressionState
end

local function saveProgressionState()
  for entity, state in pairs(ProgressionState) do
    if state.state then
      if Progression.isLocked(Progression.UnlockType.LOBBY_NPC, entity) then
        Progression.unlock(Progression.UnlockType.LOBBY_NPC, entity)
        Progression.lock(Progression.UnlockType.LOBBY_NPC_VISITED, entity)
      end
    else
      if Progression.isUnlocked(Progression.UnlockType.LOBBY_NPC, entity) then
        Progression.lock(Progression.UnlockType.LOBBY_NPC, entity)
        Progression.lock(Progression.UnlockType.LOBBY_NPC_VISITED, entity)
      end
    end
  end

  ProgressionState = nil
end

local function label(entity)
  return function()
    local state = getProgressionState()[entity]
    local name = state.name
    local value

    if state.state then
      value = TextFormat.Symbol.CHECKBOX_ON
    else
      value = TextFormat.Symbol.CHECKBOX_OFF
    end

    return ("%s %s"):format(name, value)
  end
end

local function action(entity)
  return function()
    local state = getProgressionState()[entity]
    state.state = not state.state
  end
end

local function doneAction()
  saveProgressionState()
  Menu.close()
end

Event.menu.add("menuSaveNPCEditor", "SaveEditor_lobbyNPC", function(ev)
  local menu = {}
  local entries = {}

  local state = getProgressionState()

  for entity in pairs(state) do
    entries[#entries + 1] = {
      id = entity,
      label = label(entity),
      action = action(entity)
    }
  end

  entries[#entries + 1] = {
    height = 0
  }

  entries[#entries + 1] = {
    id = "_done",
    label = "Close",
    action = doneAction
  }

  menu.entries = entries
  menu.searchable = true
  menu.label = "Lobby NPCs"
  menu.escapeAction = doneAction

  ev.menu = menu
end)
