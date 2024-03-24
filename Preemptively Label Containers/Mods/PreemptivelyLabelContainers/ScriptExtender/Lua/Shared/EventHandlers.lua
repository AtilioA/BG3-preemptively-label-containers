EHandlers = {}

EHandlers.all_opened_containers = {}
EHandlers.recently_closed = {}
-- We're interested in containers/corpses, but we check for objects to avoid doing checks early
EHandlers.processed_objects = {}

-- Initializes a timer on gaining control
function EHandlers.OnGainedControl(character)
  -- Utils.DumpCharacterEntity(character)
  -- PLCPrint(2, Osi.CalculatePassiveSkill(character, "Perception"))
  Labeling.LabelNearbyContainers()
  Osi.TimerLaunch("RenameContainers", Config:getCfg().FEATURES.refresh_interval)
end

function EHandlers.OnTimerFinished(timerName)
  if timerName ~= "RenameContainers" then
    return
  end

  PLCPrint(2, "Timer finished: " .. timerName)
  Labeling.LabelNearbyContainers()

  Osi.TimerLaunch("RenameContainers", Config:getCfg().FEATURES.refresh_interval)
end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and VCHelpers.Lootable:IsLootable(item) then
    -- Utils.DumpCharacterEntity(item)
    PLCPrint(2, "UseStarted: " .. character .. " " .. item)
    EHandlers.all_opened_containers[item] = true
    -- EHandlers.processed_objects[item] = nil
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 and VCHelpers.Lootable:IsLootable(item) then
    PLCPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    EHandlers.recently_closed[item] = true
    EHandlers.processed_objects[item] = nil
    -- if  CountFilteredItems(item) ~= 0 then
    -- Call function so that the container is relabeled immediately
    Labeling.CheckAndRenameIfLootable(item, false)
    -- end
    -- if CountFilteredItems(item) == 0 then
    --   -- Call function so that the container is relabeled immediately
    -- end
  end
end

function EHandlers.OnRequestCanLoot(looter, character)
  if Osi.IsInPartyWith(looter, Osi.GetHostCharacter()) == 1 and VCHelpers.Lootable:IsLootable(character) then
    PLCPrint(2, "OnRequestCanLoot: " .. looter .. " " .. character)
    EHandlers.all_opened_containers[character] = true
    -- EHandlers.processed_objects[character] = nil
  end
end

function EHandlers.OnCharacterLootedCharacter(looter, character)
  if Osi.IsInPartyWith(looter, Osi.GetHostCharacter()) == 1 and VCHelpers.Lootable:IsLootable(character) then
    PLCPrint(2, "OnCharacterLootedCharacter: " .. looter .. " " .. character)
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

function EHandlers.OnCharacterDied(character)
  PLCPrint(2, "OnCharacterDied: " .. character .. ". Removing from processed objects.")
  EHandlers.processed_objects[character] = nil
end

return EHandlers
