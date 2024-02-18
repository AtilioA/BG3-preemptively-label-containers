Labeling = {}

Labeling.EMPTY_STRING_HANDLE = "h823595e6g550fg4614gb1ddgdcd323bb4c69"
Labeling.ACTIVE_SEARCH_RADIUS = 5
Labeling.MIN_DISTANCE_PARTY_MEMBER = 8

function Labeling.UpdateAllEntities()
    local namedEntities = Ext.Entity.GetAllEntitiesWithComponent("DisplayName")
    -- Check if they have your uservar set, e.g. if entity.Vars.PLCOriginalName ~= nil then. If the name is set, then set the entity's name to your saved name. You can call Osi.SetStoryDisplayName again to do this.
    for _, entity in ipairs(namedEntities) do
        local originalName = entity.Vars.PLCOriginalName
        if originalName ~= nil then
            Utils.DebugPrint(2, "Initializing name for: " .. originalName)
            Osi.SetStoryDisplayName(entity.Uuid.EntityUuid, originalName)
        end
    end
end

function Labeling.LabelContainersNearbyCharacter(character)
    local shouldSimulateController = JsonConfig.FEATURES.label.simulate_controller
    local radius = JsonConfig.FEATURES.radius
    if shouldSimulateController then
        radius = math.max(radius, Labeling.ACTIVE_SEARCH_RADIUS + 1)
    end

    local nearbyContainers = GetNearbyCharactersAndItems(character, radius, true, true)
    Utils.DebugPrint(3, "Nearby items: " .. #nearbyContainers)

    if not shouldSimulateController then
        for _, member in ipairs(nearbyContainers) do
            Labeling.ProcessContainer(member.Guid, false)
        end
    else
        -- REVIEW: Might be worth to replace with a binary search (I'm too hungry to think about it right now)
        for _, member in ipairs(nearbyContainers) do
            if member.Distance <= Labeling.ACTIVE_SEARCH_RADIUS then
                -- First pass: Label with padding within the AS radius
                Labeling.ProcessContainer(member.Guid, true)
            elseif member.Distance > Labeling.ACTIVE_SEARCH_RADIUS then
                -- Second pass: Label without padding outside AS radius, but within the configured radius
                Labeling.ProcessContainer(member.Guid, false)
            end
        end
    end
end

function Labeling.LabelNearbyContainersForAllPartyMembers()
    local partyMembers = Utils.GetPartyMembers()
    local hostCharacter = Osi.GetHostCharacter()
    local minDistance = math.max(Labeling.MIN_DISTANCE_PARTY_MEMBER, JsonConfig.FEATURES.radius)

    Labeling.LabelContainersNearbyCharacter(hostCharacter)
    for _, partyMember in ipairs(partyMembers) do
        if Osi.GetDistanceTo(partyMember, hostCharacter) >= minDistance then
            Labeling.LabelContainersNearbyCharacter(partyMember)
        end
    end
end

function Labeling.LabelNearbyContainers()
    local shouldLabelAllPartyMembers = JsonConfig.FEATURES.also_check_for_party_members

    if shouldLabelAllPartyMembers then
        Labeling.LabelNearbyContainersForAllPartyMembers()
    else
        Labeling.LabelContainersNearbyCharacter(Osi.GetHostCharacter())
    end
end

function Labeling.ProcessContainer(guid, shouldPadLabel)
    local processed = EHandlers.processed_objects[guid]
    local recentlyClosed = EHandlers.recently_closed[guid]
    local isNewOrReopened = not processed or recentlyClosed
    local shouldSkipChecks = JsonConfig.DEBUG.always_relabel or JsonConfig.FEATURES.label.simulate_controller

    if shouldSkipChecks or isNewOrReopened then
        Utils.DebugPrint(3, "Processing object: " .. guid)
        Labeling.CheckAndRenameIfLootable(guid, shouldPadLabel)
        EHandlers.processed_objects[guid] = true
        EHandlers.recently_closed[guid] = nil
    else
        Utils.DebugPrint(3, "Object already processed: " .. guid)
    end
end

-- Function to check if the container is empty and change its name
-- TODO: object must not be in EHandlers.all_opened_containers. If it is, call RemoveEmptyName
function Labeling.CheckAndRenameIfLootable(object, shouldPadLabel)
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
                Utils.DebugPrint(3, "Setting label for: " .. object)
                SetNewLabel(object, shouldPadLabel)
            end
        else
            Utils.DebugPrint(3, "Not labeling: " .. object)
        end
    else
        Utils.DebugPrint(2, "Failed perception check for: " .. object)
    end
end

-- Function to create a label based on the item count
local function CreateLabel(count, displayItemCount, displayCountIfEmpty, addParentheses, capitalize)
    if displayItemCount and (count > 0 or displayCountIfEmpty) then
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
function SetNewLabel(container, shouldPadLabel)
    local entity = GetEntity(container)
    -- Utils.DebugPrint(1, "Setting container label for: " .. container)
    local objectNameHandle = entity.Vars.PLCOriginalName or GetDisplayName(entity)
    -- local name = Osi.ResolveTranslatedString(objectNameHandle)
    -- Utils.DebugPrint(2, "Container name: " .. name)
    local itemCount = CountFilteredItems(container)

    local addParentheses = JsonConfig.FEATURES.label.add_parentheses
    local capitalize = JsonConfig.FEATURES.label.capitalize
    local shouldAppend = JsonConfig.FEATURES.label.append
    local shouldDisplayNumberOfItems = JsonConfig.FEATURES.label.display_number_of_items.enabled
    local displayCountIfEmpty = JsonConfig.FEATURES.label.display_number_of_items.if_empty

    local label = CreateLabel(itemCount, shouldDisplayNumberOfItems, displayCountIfEmpty, addParentheses, capitalize)
    if shouldPadLabel and label ~= "" then -- and shouldDisplayNumberOfItems and itemCount ~= 0 then
        label = String.PadString(label, 58, objectNameHandle)
    end

    Utils.DebugPrint(3, "Label: " .. label)

    if entity ~= nil then
        if label ~= "" then
            local newDisplayName
            -- Remove newDisplayName from the objectNameHandle string if it's already there
            newDisplayName = string.gsub(objectNameHandle, label, "")
            if shouldAppend or shouldPadLabel then
                newDisplayName = objectNameHandle .. " " .. label
            else
                newDisplayName = label .. " " .. objectNameHandle
            end
            _D(entity.Vars)
            if entity.Vars.PLCOriginalName == nil then
                Utils.DebugPrint(2, "Setting original name for: " .. objectNameHandle)
                entity.Vars.PLCOriginalName = objectNameHandle
            end

            if label and string.find(objectNameHandle, label) ~= nil then
                Utils.DebugPrint(2, "Label already set for: " .. objectNameHandle)
                Osi.SetStoryDisplayName(entity.Uuid.EntityUuid, tostring(newDisplayName))
            else
                Utils.DebugPrint(2, "Setting new name for: " .. objectNameHandle .. " to " .. newDisplayName)
                Osi.SetStoryDisplayName(entity.Uuid.EntityUuid, tostring(newDisplayName))
            end
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
    Utils.DebugPrint(2, "Removing label for: " .. entity)
    Osi.SetStoryDisplayName(entity.Uuid.EntityUuid, entity.Vars.PLCOriginalName)
end

return Labeling
