local Entities    = require "system.game.Entities"
local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"
local TextFormat  = require "necro.config.i18n.TextFormat"

local Text = require "SaveEditor.i18n.Text"

local ProgressionState = nil

local function getProgressionState()
  if ProgressionState == nil then
    ProgressionState = {
      Custom = {
        state = Progression.isUnlocked(Progression.UnlockType.EXTRA_MODE, "Custom"),
        name = L("Custom mode", "extraModeCustom")
      },
      LevelEditor = {
        state = Progression.isUnlocked(Progression.UnlockType.EXTRA_MODE, "LevelEditor"),
        name = L("Level editor", "extraModeLevelEditor")
      }
    }
  end

  return ProgressionState
end

local function saveProgressionState()
  for mode, state in pairs(ProgressionState) do
    Progression.setUnlocked(Progression.UnlockType.EXTRA_MODE, mode, state.state)
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

Event.menu.add("menuSaveExtraModeEditor", "SaveEditor_extraMode", function(ev)
  local menu = {}
  local entries = {}

  getProgressionState()

  entries[1] = {
    id = "Custom",
    label = label("Custom"),
    action = action("Custom")
  }

  entries[2] = {
    id = "LevelEditor",
    label = label("LevelEditor"),
    action = action("LevelEditor")
  }

  entries[3] = {
    height = 0
  }

  entries[4] = {
    id = "_done",
    label = Text.Back,
    action = doneAction
  }

  menu.entries = entries
  menu.searchable = true
  menu.label = Text.ExtraModes
  menu.escapeAction = doneAction

  ev.menu = menu
end)
