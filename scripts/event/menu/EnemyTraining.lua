local Boss               = require "necro.game.level.Boss"
local Controls           = require "necro.config.Controls"
local EnemySubstitutions = require "necro.game.system.EnemySubstitutions"
local Entities           = require "system.game.Entities"
local Event              = require "necro.event.Event"
local Menu               = require "necro.menu.Menu"
local Progression        = require "necro.game.system.Progression"
local TextFormat         = require "necro.config.i18n.TextFormat"

local ProgressionState = nil
local EnemyOrder = nil
local MinibossOrder = nil
local BossOrder = nil

local function getProgressionState()
  if ProgressionState == nil then
    ProgressionState = {}
    EnemyOrder = {}
    MinibossOrder = {}
    BossOrder = {}

    for _, entity in Entities.prototypesWithComponents({ "enemyUnlockOnDeath" }) do
      if entity.enemyPoolZone1 or entity.enemyPoolZone2 or entity.enemyPoolZone3 or entity.enemyPoolZone4 or
          entity.enemyPoolZone5 then
        ProgressionState[entity.name] = {
          state = Progression.isUnlocked(Progression.UnlockType.ENEMY_TRAINING, entity.name),
          name = entity.friendlyName.name
        }
        EnemyOrder[#EnemyOrder + 1] = { name = entity.name, sortName = entity.friendlyName.name }
      end
    end

    for _, entity in Entities.prototypesWithComponents({ "enemyPoolMiniboss" }) do
      if not entity.enemySubstitutions or
          not entity.enemySubstitutions.types[EnemySubstitutions.Type.ITEM_PEACE] then
        ProgressionState[entity.name] = {
          state = Progression.isUnlocked(Progression.UnlockType.ENEMY_TRAINING, entity.name),
          name = entity.friendlyName.name
        }
        MinibossOrder[#MinibossOrder + 1] = { name = entity.name, sortName = entity.friendlyName.name }
      end
    end

    for _, bosstype in ipairs(Boss.Type.data) do
      local entity = Entities.getEntityPrototype(bosstype.entity)
      ProgressionState[entity.name] = {
        state = Progression.isUnlocked(Progression.UnlockType.ENEMY_TRAINING, entity.name),
        name = entity.friendlyName.name
      }
      BossOrder[#BossOrder + 1] = { name = entity.name, sortName = entity.friendlyName.name }
    end

    table.sort(EnemyOrder, function(a, b) return a.sortName < b.sortName end)
    table.sort(MinibossOrder, function(a, b) return a.sortName < b.sortName end)
    table.sort(BossOrder, function(a, b) return a.sortName < b.sortName end)
  end

  return ProgressionState
end

local function saveProgressionState()
  for entity, state in pairs(ProgressionState) do
    Progression.setUnlocked(Progression.UnlockType.ENEMY_TRAINING, entity, state.state)
  end

  ProgressionState = nil
end

local function label(entity)
  return function()
    print(entity)
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

Event.menu.add("menuSaveEnemyTrainingEditor", "SaveEditor_enemyTraining", function(ev)
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

  entries[4] = {
    id = "_jumpLabel",
    label = L.formatKey("Use %s/%s on headers to jump between sections!", "jumpLabel",
      Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_LEFT),
      Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_RIGHT)),
    font = {
      fillColor = -1,
      font = "gfx/necro/font/necrosans-6.png;",
      shadowColor = -16777216,
      size = 6
    }
  }

  entries[5] = {
    id = "_enemies",
    label = TextFormat.underline(L("Enemies", "enemies")),
    action = function() end,
    leftAction = function() Menu.selectByID("_bosses") end,
    rightAction = function() Menu.selectByID("_minibosses") end
  }

  for _, entity in ipairs(EnemyOrder) do
    local prototype = Entities.getEntityPrototype(entity.name)

    entries[#entries + 1] = {
      id = prototype,
      label = label(prototype),
      action = action(prototype)
    }
  end

  entries[#entries + 1] = {
    height = 0
  }

  entries[#entries + 1] = {
    id = "_minibosses",
    label = TextFormat.underline(L("Minibosses", "minibosses")),
    action = function() end,
    leftAction = function() Menu.selectByID("_enemies") end,
    rightAction = function() Menu.selectByID("_bosses") end
  }

  for _, entity in ipairs(MinibossOrder) do
    local prototype = Entities.getEntityPrototype(entity.name)

    entries[#entries + 1] = {
      id = prototype,
      label = label(prototype),
      action = action(prototype)
    }
  end

  entries[#entries + 1] = {
    height = 0
  }

  entries[#entries + 1] = {
    id = "_bosses",
    label = TextFormat.underline(L("Bosses", "bosses")),
    action = function() end,
    leftAction = function() Menu.selectByID("_minibosses") end,
    rightAction = function() Menu.selectByID("_enemies") end
  }

  for _, entity in ipairs(BossOrder) do
    local prototype = Entities.getEntityPrototype(entity.name)

    entries[#entries + 1] = {
      id = prototype,
      label = label(prototype),
      action = action(prototype)
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
