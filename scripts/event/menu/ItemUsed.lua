local Entities    = require "system.game.Entities"
local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"
local TextFormat  = require "necro.config.i18n.TextFormat"

local KeyBank = require "SaveEditor.i18n.KeyBank"

local ProgressionState = nil
local EntityOrder = nil

local function getProgressionState()
  if ProgressionState == nil then
    ProgressionState = {}
    EntityOrder = {}

    for _, entity in Entities.prototypesWithComponents({ "itemUnlockOnPickup" }) do
      if entity.itemUnlockOnPickup.key == entity.name then
        ProgressionState[entity.name] = {
          state = Progression.isUnlocked(Progression.UnlockType.ITEM_USED, entity.name),
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
    Progression.setUnlocked(Progression.UnlockType.ITEM_USED, entity, state.state)
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

Event.menu.add("menuSaveItemUsedEditor", "SaveEditor_itemUsed", function(ev)
  local menu = {}
  local entries = {}

  getProgressionState()

  entries[1] = {
    id = "_selectAll",
    label = KeyBank.SelectAll,
    action = selectAll
  }

  entries[2] = {
    id = "_deselectAll",
    label = KeyBank.DeselectAll,
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
    label = KeyBank.Back,
    action = doneAction
  }

  menu.entries = entries
  menu.searchable = true
  menu.label = KeyBank.ItemUsed
  menu.escapeAction = doneAction

  ev.menu = menu
end)
