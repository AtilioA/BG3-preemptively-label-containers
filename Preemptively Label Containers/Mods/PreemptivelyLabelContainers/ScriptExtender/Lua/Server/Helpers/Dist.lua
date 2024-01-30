-- Adapted from FocusBG3: https://www.nexusmods.com/baldursgate3/mods/5972

---@param origin vec3
---@param target vec3
---@param ignoreHeight? boolean
---@return number
function GetDistance(origin, target, ignoreHeight)
    ignoreHeight = ignoreHeight == nil or ignoreHeight
    return math.sqrt(
        (origin[1] - target[1]) ^ 2
        + ((ignoreHeight and 0) or (origin[2] - target[2]) ^ 2)
        + (origin[3] - target[3]) ^ 2
    )
end

--Returns a distance-sorted array of characters nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean
---@return {Entity:EntityHandle, Guid:Guid, Distance:number, Name:string}[]
function GetNearbyCharacters(source, radius, ignoreHeight)
    local sourceEntity = GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or JsonConfig.FEATURES.radius

    local nearbyEntities = {}
    for _, character in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsCharacter")) do
        if character.Transform and character.Transform.Transform then
            local distance = GetDistance(pos, character.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius then
                table.insert(nearbyEntities, {
                    Entity = character,
                    Guid = character.Uuid.EntityUuid,
                    Distance = distance,
                    Name = Ext.Loca.GetTranslatedString(character.DisplayName.NameKey.Handle.Handle)
                })
            end
        end
    end

    table.sort(nearbyEntities, function(a, b) return a.Distance < b.Distance end)
    return nearbyEntities
end

--Returns a distance-sorted array of items nearby a position or object
---@param source EntityHandle|Guid|vec3
---@param radius? number
---@param ignoreHeight? boolean
---@param includeInSourceInventory? boolean
---@return {Entity: EntityHandle, Guid: Guid, Distance:number, Name:string, Template:Guid}[]
function GetNearbyContainers(source, radius, ignoreHeight, includeInSourceInventory)
    local sourceEntity = GetEntity(source)
    local pos = sourceEntity ~= nil and sourceEntity.Transform.Transform.Translate or source
    radius = radius or JsonConfig.FEATURES.radius

    local nearbyEntities = {}
    if includeInSourceInventory or not sourceEntity then
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            if item.Transform and item.Transform.Transform then
                local distance = GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
                if distance <= radius then
                    table.insert(nearbyEntities, {
                        Entity = item,
                        Guid = item.Uuid.EntityUuid,
                        Distance = distance,
                        Name = Ext.Loca.GetTranslatedString(item.DisplayName.NameKey.Handle.Handle),
                        TemplateId = item.ServerItem.Template.Id
                    })
                end
            end
        end
    else
        for _, item in ipairs(Ext.Entity.GetAllEntitiesWithComponent("IsItem")) do
            local distance = GetDistance(pos, item.Transform.Transform.Translate, ignoreHeight)
            if distance <= radius and not Helpers.Inventory:ItemIsInInventory(item, sourceEntity) then
                table.insert(nearbyEntities, {
                    Entity = item,
                    Guid = item.Uuid.EntityUuid,
                    Distance = distance,
                    Name = Ext.Loca.GetTranslatedString(item.DisplayName.NameKey.Handle.Handle),
                    TemplateId = item.ServerItem.Template.Id
                })
            end
        end
    end

    table.sort(nearbyEntities, function(a, b) return a.Distance < b.Distance end)
    return nearbyEntities
end

-- Main function to get both nearby characters and items
function GetNearbyCharactersAndItems(source, radius, ignoreHeight, includeInSourceInventory)
    local characters = GetNearbyCharacters(source, radius, ignoreHeight)
    local items = GetNearbyContainers(source, radius, ignoreHeight, includeInSourceInventory)

    -- Combine characters and items into a single table
    local allNearbyEntities = {}
    for _, entity in ipairs(characters) do
        table.insert(allNearbyEntities, entity)
    end
    for _, entity in ipairs(items) do
        table.insert(allNearbyEntities, entity)
    end

    -- Sort the combined list by distance
    table.sort(allNearbyEntities, function(a, b) return a.Distance < b.Distance end)

    return allNearbyEntities
end

-- Function to get the display name of the entity
---@param entity EntityHandle
---@return string
function GetDisplayName(entity)
    -- Utils.DebugPrint(2, "Getting display name of entity: " .. entity)
    local name = ""
    if entity.DisplayName ~= nil then
        name = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle)
        -- _D(name)
        if name == nil then
            name = entity.DisplayName.Name
            -- if (name == "" or name == nil) and self.IsServer then
            --     name = Ext.Loca.GetTranslatedString(Ext.Template.GetTemplate(entity.OriginalTemplate.OriginalTemplate)
            --         .DisplayName.Handle.Handle)
            -- end
        end
    end
    return name
end
