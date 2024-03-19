EHandlers = {}

EHandlers.all_opened_containers = {}
EHandlers.recently_closed = {}
-- We're interested in containers/corpses, but we check for objects to avoid doing checks early
EHandlers.processed_objects = {}

-- Initializes a timer on gaining control
function EHandlers.OnGainedControl(character)
  -- Labeling.RestoreEntitiesLabels()
  Labeling.LabelNearbyContainers()
  Osi.TimerLaunch("RenameContainers", JsonConfig.FEATURES.refresh_interval)
end

function EHandlers.OnTimerFinished(timerName)
  if timerName ~= "RenameContainers" then
    return
  end

  Utils.DebugPrint(3, "Timer finished: " .. timerName)
  Labeling.LabelNearbyContainers()

  Osi.TimerLaunch("RenameContainers", JsonConfig.FEATURES.refresh_interval)
end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and Loot.IsLootable(item) then
    -- Utils.DumpCharacterEntity(item)
    Utils.DebugPrint(2, "UseStarted: " .. character .. " " .. item)
    EHandlers.all_opened_containers[item] = true
    -- EHandlers.processed_objects[item] = nil
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and Loot.IsLootable(item) then
    Utils.DebugPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    EHandlers.recently_closed[item] = true
    EHandlers.processed_objects[item] = nil
    -- if  CountFilteredItems(item) ~= 0 then
    -- Call function so that the container is relabeled immediately
    if not ItemIsInPartyInventory(item, character) then
      Labeling.LabelContainersNearbyCharacter(character)
    else
      Utils.DebugPrint(2, "Not relabeling " .. item .. " because it's in the party's inventory.")
    end
    -- end
    -- if CountFilteredItems(item) == 0 then
    --   -- Call function so that the container is relabeled immediately
    -- end
  end
end

function EHandlers.OnRequestCanLoot(looter, character)
  if Osi.IsInPartyWith(looter, Osi.GetHostCharacter()) == 1 and Loot.IsLootable(character) then
    Utils.DebugPrint(2, "OnRequestCanLoot: " .. looter .. " " .. character)
    EHandlers.all_opened_containers[character] = true
    -- EHandlers.processed_objects[character] = nil
  end
end

function EHandlers.OnCharacterLootedCharacter(looter, character)
  if Osi.IsInPartyWith(looter, Osi.GetHostCharacter()) == 1 and Loot.IsLootable(character) then
    Utils.DebugPrint(2, "OnCharacterLootedCharacter: " .. looter .. " " .. character)
    -- Utils.DumpCharacterEntity(character)
    EHandlers.recently_closed[character] = true
    EHandlers.processed_objects[character] = nil
    -- if  CountFilteredCharacters(character) ~= 0 then
    -- Call function so that the container is relabeled immediately
    Labeling.CheckAndRenameIfLootable(character, false)
    -- end
    -- if CountFilteredCharacters(character) == 0 then
    --   -- Call function so that the container is relabeled immediately
    -- end
  end
end

-- Reload the config if moving gold to a container
function EHandlers.OnMovedFromTo(movedObject, fromObject, toObject, isTrade)
  Utils.DebugPrint(2, "OnMovedFromTo: " .. movedObject .. " " .. fromObject .. " " .. toObject .. " " .. isTrade)
  if Osi.IsInPartyWith(Osi.GetHostCharacter(), fromObject) == 1 and isTrade == 0 then
    if Utils.GetUID(movedObject) == 'LOOT_Gold_A' and Osi.IsContainer(toObject) == 1 then
      JsonConfig = Config.LoadJSONConfig()
      EHandlers.all_opened_containers = {}
      EHandlers.recently_closed = {}
      EHandlers.processed_objects = {}
      Osi.TimerLaunch("RenameContainers", 1)
    end
  end
end

function EHandlers.OnCharacterDied(character)
  Utils.DebugPrint(2, "OnCharacterDied: " .. character .. ". Removing from processed objects.")
  EHandlers.processed_objects[character] = nil
end

function EHandlers.OnGameStateChange(gameState)
  if gameState.FromState == "LoadLevel" and gameState.ToState == "Sync" then
    Labeling.RestoreEntitiesLabels()
    Labeling.LabelNearbyContainers()
  end
end

return EHandlers
