EHandlers = {}

EHandlers.opened_containers = {}

function EHandlers.OnGainedControl(character)
  Osi.TimerLaunch("RenameContainers", JsonConfig.FEATURES.refresh_interval)
end

function EHandlers.OnTimerFinished(timerName)
  if timerName ~= "RenameContainers" then
    return
  end

  local nearbyContainers = GetNearbyCharactersAndItems(Osi.GetHostCharacter(), JsonConfig.FEATURES.radius, true, true)
  Utils.DebugPrint(3, "Nearby items: " .. #nearbyContainers)
  for _, member in ipairs(nearbyContainers) do
    CheckAndRenameEmptyContainer(member.Guid)
  end
  Osi.TimerLaunch("RenameContainers", JsonConfig.FEATURES.refresh_interval)
end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "UseEnded: " .. character .. " " .. item)
    if IsLootable(item) then
      if CountFilteredItems(item) == 0 then
        table.insert(EHandlers.opened_containers, item.Guid)
      end
    end
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, Osi.GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    if IsLootable(item) then
      if CountFilteredItems(item) == 0 and not Utils.TableContains(EHandlers.opened_containers, item.Guid) then
        table.insert(EHandlers.opened_containers, item.Guid)
      end
    end
  end
end

return EHandlers
