Loot = {}

function Loot.IsCorpse(object)
  -- TODO: add knocked out check
  return GetInventory(object, true, true) ~= nil and Osi.IsDead(object) == 1
end

function Loot.IsLootable(object)
  return (Osi.IsContainer(object) == 1) or Loot.IsCorpse(object)
end

return Loot
