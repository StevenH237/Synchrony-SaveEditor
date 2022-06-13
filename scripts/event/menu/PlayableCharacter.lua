local Entities    = require "system.game.Entities"
local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"

local ProgressionState = nil

local function getProgressionState()
  if ProgressionState == nil then
    ProgressionState = {}

    for _, entity in Entities.prototypesWithComponents({ "playableCharacter" }) do
      local newPlayer = {
        unlockable = entity.playableCharacterUnlockable ~= nil,
        state = 1,
        name = entity.friendlyName.name
      }

      -- Figure out where we're already at
      -- If the character is unlockable, is it unlocked?
      if newPlayer.unlockable then
        if not Progression.isUnlocked(Progression.UnlockType.PLAYABLE_CHARACTER, entity.name) then
          newPlayer.state = 0
          goto nextEntity
        end
      end

      -- Has depth 1 been cleared?
      if Progression.isUnlocked(Progression.UnlockType.DEPTH_2, entity.name) then
        newPlayer.state = 2
      else
        goto nextEntity
      end

      -- Has depth 2 been cleared?
      if Progression.isUnlocked(Progression.UnlockType.DEPTH_3, entity.name) then
        newPlayer.state = 3
      else
        goto nextEntity
      end

      -- Has depth 3 been cleared?
      if Progression.isUnlocked(Progression.UnlockType.DEPTH_4, entity.name) then
        newPlayer.state = 4
      end

      ::nextEntity::
      ProgressionState[entity.name] = newPlayer
    end
  end

  return ProgressionState
end

local function unlockIf(uType, name, minimum, value)
  if value >= minimum then
    Progression.unlock(uType, name)
  else
    Progression.lock(uType, name)
  end
end

local function saveProgressionState()
  for entity, state in pairs(ProgressionState) do
    unlockIf(Progression.UnlockType.PLAYABLE_CHARACTER, entity, 1, state.state)
    unlockIf(Progression.UnlockType.DEPTH_2, entity, 2, state.state)
    unlockIf(Progression.UnlockType.DEPTH_3, entity, 3, state.state)
    unlockIf(Progression.UnlockType.DEPTH_4, entity, 4, state.state)
  end

  ProgressionState = nil
end

local function label(entity)
  return function()
    local state = getProgressionState()[entity]
    local name = state.name
    local value

    if state.state == 0 then
      value = L("Locked", "characterLocked")
    elseif state.state == 1 and state.unlockable then
      value = L("Unlocked", "characterUnlocked")
    elseif state.state == 1 and not state.unlockable then
      value = L("No clears yet", "characterDepth1")
    elseif state.state == 2 then
      value = L("Cleared depth 1", "characterDepth2")
    elseif state.state == 3 then
      value = L("Cleared depth 2", "characterDepth3")
    elseif state.state == 4 then
      value = L("Cleared depth 3", "characterDepth4")
    end

    return ("%s: %s"):format(name, value)
  end
end

local function leftAction(entity)
  return function()
    local state = getProgressionState()[entity]
    if state.state >= 2 or (state.unlockable and state.state == 1) then
      state.state = state.state - 1
    end
  end
end

local function rightAction(entity)
  return function()
    local state = getProgressionState()[entity]
    if state.state <= 3 then
      state.state = state.state + 1
    end
  end
end

local function doneAction()
  saveProgressionState()
  Menu.close()
end

Event.menu.add("menuSavePlayerEditor", "SaveEditor_playableCharacter", function(ev)
  local menu = {}
  local entries = {}

  local state = getProgressionState()

  for entity in pairs(state) do
    entries[#entries + 1] = {
      id = entity,
      label = label(entity),
      leftAction = leftAction(entity),
      rightAction = rightAction(entity),
      action = rightAction(entity)
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
  menu.label = "Playable characters"
  menu.escapeAction = doneAction

  ev.menu = menu
end)
