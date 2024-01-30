EHandlers = {}

EHandlers.all_opened_containers = {}
EHandlers.recently_closed = {}
-- We're interested in containers/corpses, but we check for objects to avoid doing checks early
EHandlers.processed_objects = {}

-- Initializes a timer on gaining control
function EHandlers.OnGainedControl(character)
  Labeling.LabelNearbyContainers()
  Osi.TimerLaunch("RenameContainers", JsonConfig.FEATURES.refresh_interval)
end

function EHandlers.OnTimerFinished(timerName)
  if timerName ~= "RenameContainers" then
    return
  end

  Utils.DebugPrint(2, "Timer finished: " .. timerName)
  Labeling.LabelNearbyContainers()

  Osi.TimerLaunch("RenameContainers", JsonConfig.FEATURES.refresh_interval)
end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and IsLootable(item) then
    Utils.DebugPrint(2, "UseStarted: " .. character .. " " .. item)
    EHandlers.all_opened_containers[item] = true
    -- EHandlers.processed_objects[item] = nil
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and IsLootable(item) then
    Utils.DebugPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    EHandlers.recently_closed[item] = true
    EHandlers.processed_objects[item] = nil
    -- if  CountFilteredItems(item) ~= 0 then
    -- Call function so that the container is relabeled immediately
    CheckAndRenameEmptyContainer(item)
    -- end
    -- if CountFilteredItems(item) == 0 then
    --   -- Call function so that the container is relabeled immediately
    -- end
  end
end

function EHandlers.OnRequestCanLoot(character, item)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and IsLootable(item) then
    Utils.DebugPrint(2, "OnRequestCanLoot: " .. character .. " " .. item)
    EHandlers.all_opened_containers[item] = true
    EHandlers.processed_objects[item] = nil
  end
end

function EHandlers.OnCharacterLootedCharacter(character, item)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and IsLootable(item) then
    Utils.DebugPrint(2, "OnCharacterLootedCharacter: " .. character .. " " .. item)
    EHandlers.recently_closed[item] = true
    EHandlers.processed_objects[item] = nil
    -- if  CountFilteredItems(item) ~= 0 then
    -- Call function so that the container is relabeled immediately
    CheckAndRenameEmptyContainer(item)
    -- end
    -- if CountFilteredItems(item) == 0 then
    --   -- Call function so that the container is relabeled immediately
    -- end
  end
end

return EHandlers
