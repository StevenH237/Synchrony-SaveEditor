local Entities    = require "system.game.Entities"
local Event       = require "necro.event.Event"
local Menu        = require "necro.menu.Menu"
local Progression = require "necro.game.system.Progression"
local TextFormat  = require "necro.config.i18n.TextFormat"

local KeyBank = require "SaveEditor.i18n.KeyBank"

local ProgressionEntities = nil
local ProgressionStats    = nil

local function getProgressionEntities()
  if ProgressionEntities == nil then
    ProgressionEntities = {}
    ProgressionStats = {
      Hearts = 0,
      Coins = 0
    }

    for _, entity in Entities.prototypesWithComponents({ "itemLobbyProgressionUnlock" }) do
      if ({ PermHeart2 = true, PermHeart3 = true, PermHeart4 = true, PermHeart5 = true, PermHeart6 = true })[entity.name
          ] then
        if Progression.isUnlocked(Progression.UnlockType.ITEM_GRANT_PERMANENT, entity.name) then
          ProgressionStats.Hearts = ProgressionStats.Hearts + 1
        end
      elseif ({ CoinsX15 = true, CoinsX2 = true })[entity.name] then
        if Progression.isUnlocked(Progression.UnlockType.ITEM_GRANT_PERMANENT, entity.name) then
          ProgressionStats.Coins = ProgressionStats.Coins + 1
        end
      else
        ProgressionEntities[entity.name] = {
          state = Progression.isUnlocked(Progression.UnlockType.ITEM_GRANT_PERMANENT, entity.name),
          name = entity.friendlyName.name
        }
      end
    end
  end

  return ProgressionEntities
end

local function getProgressionStats()
  if ProgressionStats == nil then
    getProgressionEntities()
  end

  return ProgressionStats
end

local function unlockIf(entity, minimum, value)
  if value >= minimum then
    Progression.unlock(Progression.UnlockType.ITEM_GRANT_PERMANENT, entity)
  else
    Progression.lock(Progression.UnlockType.ITEM_GRANT_PERMANENT, entity)
  end
end

local function saveProgressionEntities()
  for entity, state in pairs(ProgressionEntities) do
    Progression.setUnlocked(Progression.UnlockType.ITEM_GRANT_PERMANENT, entity, state.state)
  end

  unlockIf("PermHeart2", 1, ProgressionStats.Hearts)
  unlockIf("PermHeart3", 2, ProgressionStats.Hearts)
  unlockIf("PermHeart4", 3, ProgressionStats.Hearts)
  unlockIf("PermHeart5", 4, ProgressionStats.Hearts)
  unlockIf("PermHeart6", 5, ProgressionStats.Hearts)

  unlockIf("CoinsX15", 1, ProgressionStats.Coins)
  unlockIf("CoinsX2", 2, ProgressionStats.Coins)

  ProgressionEntities = nil
  ProgressionStats = nil
end

local function label(entity)
  return function()
    local state = getProgressionEntities()[entity]
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

local function labelCoins()
  local state = getProgressionStats()

  return L.formatKey("Coin upgrades: %i", "coinLabel", state.Coins)
end

local function lowerCoins()
  local state = getProgressionStats()
  if state.Coins >= 1 then
    state.Coins = state.Coins - 1
  end
end

local function raiseCoins()
  local state = getProgressionStats()
  if state.Coins <= 1 then
    state.Coins = state.Coins + 1
  end
end

local function labelHearts()
  local state = getProgressionStats()

  return L.formatKey("Heart upgrades: %i", "coinLabel", state.Hearts)
end

local function lowerHearts()
  local state = getProgressionStats()
  if state.Hearts >= 1 then
    state.Hearts = state.Hearts - 1
  end
end

local function raiseHearts()
  local state = getProgressionStats()
  if state.Hearts <= 4 then
    state.Hearts = state.Hearts + 1
  end
end

local function action(entity)
  return function()
    local state = getProgressionEntities()[entity]
    state.state = not state.state
  end
end

local function doneAction()
  saveProgressionEntities()
  Menu.close()
end

Event.menu.add("menuSaveProgressionEditor", "SaveEditor_itemGrantPermanent", function(ev)
  local menu = {}
  local entries = {}

  local state = getProgressionEntities()

  entries[1] = {
    id = "_Coins",
    label = labelCoins,
    leftAction = lowerCoins,
    rightAction = raiseCoins,
    action = raiseCoins
  }

  entries[2] = {
    id = "_Hearts",
    label = labelHearts,
    leftAction = lowerHearts,
    rightAction = raiseHearts,
    action = raiseHearts
  }

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
    label = KeyBank.Back,
    action = doneAction
  }

  menu.entries = entries
  menu.searchable = true
  menu.label = L("Lobby NPCs", "permanentUpgradeTitle")
  menu.escapeAction = doneAction

  ev.menu = menu
end)
