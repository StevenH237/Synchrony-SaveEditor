local Entities    = require "system.game.Entities"
local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"
local TextFormat  = require "necro.config.i18n.TextFormat"

local ProgressionState = nil
local EntityOrder = nil

local function getProgressionState()
  if ProgressionState == nil then
    ProgressionState = {}
    EntityOrder = {}

    for _, entity in Entities.prototypesWithComponents({ "itemUnlockable", "itemPrice" }) do
      if (not (entity.itemUnlockable.key ~= entity.name or entity.itemCurrency or entity.itemLobbyProgressionUnlock)) and
          entity.itemPrice.diamonds then
        ProgressionState[entity.name] = {
          state = Progression.isUnlocked(Progression.UnlockType.ITEM_POOL, entity.name),
          name = entity.friendlyName.name
        }
        EntityOrder[#EntityOrder + 1] = entity
      end
    end

    table.sort(EntityOrder, function(a, b) return a.friendlyName.name < b.friendlyName.name end)
  end

  return ProgressionState
end

local function saveProgressionState()
  for entity, state in pairs(ProgressionState) do
    Progression.setUnlocked(Progression.UnlockType.ITEM_POOL, entity, state.state)
  end

  ProgressionState = nil
end

local function label(entity)
  return function()
    local state = getProgressionState()[entity.name]
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

local function selectAll()
  for entity, state in pairs(ProgressionState) do
    state.state = true
  end
end

local function deselectAll()
  for entity, state in pairs(ProgressionState) do
    state.state = false
  end
end

local function doneAction()
  saveProgressionState()
  Menu.close()
end

Event.menu.add("menuSaveItemPoolEditor", "SaveEditor_itemPool", function(ev)
  local menu = {}
  local entries = {}

  getProgressionState()

  entries[1] = {
    id = "_selectAll",
    label = L("Select all", "selectAll"),
    action = selectAll
  }

  entries[2] = {
    id = "_deselectAll",
    label = L("Deselect all", "deselectAll"),
    action = deselectAll
  }

  entries[3] = {
    height = 0
  }

  for _, entity in ipairs(EntityOrder) do
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
