Labeling = {}

Labeling.EMPTY_STRING_HANDLE = "h823595e6g550fg4614gb1ddgdcd323bb4c69"


function Labeling.LabelNearbyContainers()
    local nearbyContainers = GetNearbyCharactersAndItems(Osi.GetHostCharacter(), JsonConfig.FEATURES.radius, true, true)
    Utils.DebugPrint(3, "Nearby items: " .. #nearbyContainers)

    for _, member in ipairs(nearbyContainers) do
        local processed = EHandlers.processed_objects[member.Guid]
        local recentlyClosed = EHandlers.recently_closed[member.Guid]
        local isNewOrReopened = not processed or recentlyClosed
        if isNewOrReopened then
            Utils.DebugPrint(2, "Processing object: " .. member.Guid)
            CheckAndRenameIfLootable(member.Guid)
            EHandlers.processed_objects[member.Guid] = true
            EHandlers.recently_closed[member.Guid] = nil
        else
            Utils.DebugPrint(3, "Object already processed: " .. member.Guid)
        end
    end
end

-- Function to check if the container is empty and change its name
-- TODO: object must not be in EHandlers.all_opened_containers. If it is, call RemoveEmptyName
function CheckAndRenameIfLootable(object)
    local shouldLabelOwned = (Osi.QRY_CrimeItemHasNPCOwner(object) == 0) or JsonConfig.FEATURES.labeling
        .owned_containers
    local shouldRemoveFromOpened = JsonConfig.FEATURES.labeling.remove_from_opened
    local perceptionDC = JsonConfig.FEATURES.labeling.perception_check_dc

    if perceptionDC <= 1 or (Dice.RollPerception(Osi.GetHostCharacter(), perceptionDC)) then
        if Loot.IsLootable(object) and shouldLabelOwned then
            -- This will also remove numeric labels (i.e., not only Empty labels)
            if shouldRemoveFromOpened and EHandlers.all_opened_containers[object] then
                Utils.DebugPrint(2, "Removing label for: " .. object)
                RemoveLabel(object)
            else
                Utils.DebugPrint(2, "Setting label for: " .. object)
                SetNewLabel(object)
            end
        else
            Utils.DebugPrint(3, "Not labeling: " .. object)
        end
    else
        Utils.DebugPrint(2, "Failed perception check for: " .. object)
    end
end

-- Function to create a label based on the item count
local function CreateLabel(count, displayItemCount, addParentheses, capitalize)
    if displayItemCount then
        return "(" .. count .. ")"
    elseif count == 0 then
        local translatedString = String.RemoveParentheses(Ext.Loca.GetTranslatedString(Labeling.EMPTY_STRING_HANDLE))

        if capitalize then
            translatedString = String.Capitalize(translatedString)
        else
            translatedString = String.Lowercase(translatedString)
        end

        if addParentheses then
            translatedString = String.AddParentheses(translatedString)
        end

        return translatedString
    elseif JsonConfig.DEBUG.level >= 3 then
        return "NO_LABEL"
    else
        return ""
    end
end

-- Function to set the container's name as empty or with item count
---@param container EntityHandle
function SetNewLabel(container)
    -- Utils.DebugPrint(1, "Setting container label for: " .. container)
    local objectNameHandle = GetDisplayName(GetEntity(container))
    -- local name = Osi.ResolveTranslatedString(objectNameHandle)
    -- Utils.DebugPrint(2, "Container name: " .. name)
    local itemCount = CountFilteredItems(container)

    local addParentheses = JsonConfig.FEATURES.label.add_parentheses
    local capitalize = JsonConfig.FEATURES.label.capitalize
    local shouldAppend = JsonConfig.FEATURES.label.append
    local shouldSimulateController = JsonConfig.FEATURES.label.simulate_controller
    local shouldDisplayNumberOfItems = JsonConfig.FEATURES.label.display_number_of_items


    local label = CreateLabel(itemCount, shouldDisplayNumberOfItems, addParentheses, capitalize)
    if shouldSimulateController and label ~= "" then -- and shouldDisplayNumberOfItems and itemCount ~= 0 then
        label = String.PadString(label, 58, objectNameHandle)
    end

    Utils.DebugPrint(2, "Label: " .. label)

    local entity = GetEntity(container)
    if entity ~= nil then
        if label ~= "" then
            local newDisplayName
            if shouldAppend or shouldSimulateController then
                newDisplayName = objectNameHandle .. " " .. label
            else
                newDisplayName = label .. " " .. objectNameHandle
            end
            entity.DisplayName.Name = newDisplayName
            entity:Replicate("DisplayName")
        end
    else -- This is a temporary workaround for containers that are not yet loaded
        Utils.DebugPrint(2, "Entity is nil")
    end
end

-- TODO: clear the extra label of a container that is opened. I don't know if we can just set it to "", but a regex replace would work.
-- After player opens a container, remove the empty label. However: "I diffed a dump of an unopened and opened version of the same item and there weren't any differences 😦"
---@param entity EntityHandle
function RemoveLabel(entityHandle)
    local entity = Ext.Entity.Get(entityHandle)
    -- Utils.DebugPrint(2, "Removing label for: " .. entity)
    entity.DisplayName.Name = ""
    entity:Replicate("DisplayName")
end

return Labeling
