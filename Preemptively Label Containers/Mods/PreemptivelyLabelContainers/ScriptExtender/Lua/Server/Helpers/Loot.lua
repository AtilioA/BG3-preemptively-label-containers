Loot = {}

function Loot.IsCorpse(object)
  -- TODO: add knocked out check
  return GetInventory(object, true, true) ~= nil and Osi.IsDead(object) == 1
end

function Loot.IsKnockedOut(object)
  local objectEntityComponents = Ext.Entity.Get(object)
  return (objectEntityComponents and objectEntityComponents.CanBeLooted and objectEntityComponents.CanBeLooted.Flags ~= 0)
end

function Loot.IsLootable(object)
  return (Osi.IsContainer(object) == 1) or Loot.IsCorpse(object) or Loot.IsKnockedOut(object)
end

return Loot
