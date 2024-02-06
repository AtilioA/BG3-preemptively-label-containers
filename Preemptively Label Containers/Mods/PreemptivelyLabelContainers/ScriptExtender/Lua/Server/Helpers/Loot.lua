Loot = {}

function Loot.IsCorpse(object)
  -- TODO: add knocked out check
  return GetInventory(object, true, true) ~= nil and Osi.IsDead(object) == 1
end

function Loot.IsKnockedOut(object)
  local objectEntityComponents = Ext.Entity.Get(object)
  return (objectEntityComponents and objectEntityComponents.CanBeLooted and objectEntityComponents.CanBeLooted.Flags ~= 0)
end

function Loot.IsBuriedChest(object)
  local objectEntity = Ext.Entity.Get(object)
  if objectEntity and objectEntity.ServerItem and objectEntity.ServerItem.Template then
    local TemplateName = objectEntity.ServerItem.Template.Name
    if string.find(TemplateName, "BuriedChest") then
      return true
    end

    -- local StatusContainer = objectEntity.StatusContainer
    local isSurfaceChest = false
    -- if StatusContainer ~= nil then
    --   local Statuses = StatusContainer.Statuses
    --   for _key, Status in pairs(Statuses) do
    --     if Status == "INSURFACE" then
    --       isSurfaceChest = true
    --     end
    --   end

    return not isSurfaceChest
  end
end

function Loot.IsLootable(object)
  return ((Osi.IsContainer(object) == 1) or Loot.IsCorpse(object) or Loot.IsKnockedOut(object)) and
      not Loot.IsBuriedChest(object)
end

return Loot
