Labeling = {}

Labeling.EMPTY_STRING_HANDLE = "h823595e6g550fg4614gb1ddgdcd323bb4c69"
Labeling.ACTIVE_SEARCH_RADIUS = 5
Labeling.MIN_DISTANCE_PARTY_MEMBER = 8
Labeling.HANDLE_LABEL = '_PLC_labeled'

function Labeling.LabelContainersNearbyCharacter(character)
    if VCHelpers.Character:IsCharacterInCamp(character) then
        PLCDebug(3, "Character is in camp, skipping labeling")
        return
    end

    local shouldSimulateController = MCMGet("simulate_controller")
    local radius = MCMGet("radius")
    if shouldSimulateController then
        radius = math.max(radius, Labeling.ACTIVE_SEARCH_RADIUS + 1)
    end

    local nearbyContainers = VCHelpers.Object:GetNearbyCharactersAndItems(character, radius, true, true)
    PLCPrint(3, "Nearby items: " .. #nearbyContainers)

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
    local partyMembers = VCHelpers.Party:GetPartyMembers()
    local hostCharacter = Osi.GetHostCharacter()
    local minDistance = math.max(Labeling.MIN_DISTANCE_PARTY_MEMBER, MCMGet("radius"))

    Labeling.LabelContainersNearbyCharacter(hostCharacter)
    for _, partyMember in ipairs(partyMembers) do
        if Osi.GetDistanceTo(partyMember, hostCharacter) >= minDistance then
            Labeling.LabelContainersNearbyCharacter(partyMember)
        end
    end
end

function Labeling.LabelNearbyContainers()
    local shouldLabelAllPartyMembers = MCMGet("also_check_for_party_members")

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
    local shouldSkipChecks = MCMGet("always_relabel") or
        MCMGet("simulate_controller")

    if shouldSkipChecks or isNewOrReopened then
        PLCPrint(3, "Processing object: " .. guid)
        Labeling.CheckAndRenameIfLootable(guid, shouldPadLabel)
        EHandlers.processed_objects[guid] = true
        EHandlers.recently_closed[guid] = nil
    else
        PLCPrint(3, "Object already processed: " .. guid)
    end
end

-- Function to check if the container is empty and change its name
function Labeling.CheckAndRenameIfLootable(object, shouldPadLabel)
    local shouldLabelOwned = (Osi.QRY_CrimeItemHasNPCOwner(object) == 0) or MCMGet("owned_containers")
    local shouldLabelNested = MCMGet("nested_containers") or VCHelpers.Object:IsObjectInWorld(
        object)
    local shouldRemoveFromOpened = MCMGet("remove_from_opened")
    local perceptionDC = MCMGet("perception_check_dc")

    if perceptionDC <= 0 or (Dice.RollPerception(Osi.GetHostCharacter(), perceptionDC)) then
        if VCHelpers.Lootable:IsLootable(object) and shouldLabelOwned and shouldLabelNested then
            -- This will also remove numeric labels (i.e., not only Empty labels)
            if shouldRemoveFromOpened and EHandlers.all_opened_containers[object] then
                PLCPrint(2, "Removing label for: " .. object)
                RemoveLabel(object)
            else
                PLCPrint(3, "Setting label for: " .. object)
                SetNewLabel(object, shouldPadLabel)
            end
        else
            PLCPrint(3, "Not labeling: " .. object)
        end
    else
        PLCPrint(2, "Failed perception check for: " .. object)
    end
end

-- Function to create a label based on the item count
local function CreateLabel(count, displayItemCount, displayCountIfEmpty, addParentheses, capitalize)
    if displayItemCount and (count > 0 or displayCountIfEmpty) then
        return "(" .. count .. ")"
    elseif count == 0 then
        local translatedString = LabelString.RemoveParentheses(Ext.Loca.GetTranslatedString(Labeling.EMPTY_STRING_HANDLE))

        if capitalize then
            translatedString = VCHelpers.String:Capitalize(translatedString)
        else
            translatedString = VCHelpers.String:Lowercase(translatedString)
        end

        if addParentheses then
            translatedString = LabelString.AddParentheses(translatedString)
        end

        return translatedString
    elseif MCMGet("debug_level") >= 3 then
        return "NO_LABEL"
    else
        return ""
    end
end

--- Add the Labeling.HANDLE_LABEL to the stringHandle
function CreateLabeledHandle(entity)
    return entity.DisplayName.NameKey.Handle.Handle .. Labeling.HANDLE_LABEL .. "_" .. entity.Uuid.EntityUuid
end

--- Remove the Labeling.HANDLE_LABEL from the stringHandle and everything after it (uuid)
function RemoveLabelFromHandle(stringHandle)
    local labelIndex, _ = stringHandle:find(Labeling.HANDLE_LABEL)
    if labelIndex then
        -- Remove the label and the uuid
        return stringHandle:sub(1, labelIndex - 1)
    else
        return stringHandle
    end
end

--- Return the handle if it has the Labeling.HANDLE_LABEL, otherwise return call CreateLabeledHandle
function GetLabeledHandle(entity)
    if entity.DisplayName.NameKey.Handle.Handle:find(Labeling.HANDLE_LABEL) then
        return entity.DisplayName.NameKey.Handle.Handle
    else
        return CreateLabeledHandle(entity)
    end
end

-- Function to set the container's name as empty or with item count
---@param container EntityHandle
function SetNewLabel(container, shouldPadLabel)
    -- PLCPrint(1, "Setting container label for: " .. container)
    local objectNameHandle = VCHelpers.Object:GetEntity(container).DisplayName.NameKey.Handle.Handle
    local originalName = Ext.Loca.GetTranslatedString(RemoveLabelFromHandle(objectNameHandle))
    -- local name = Osi.ResolveTranslatedString(objectNameHandle)
    -- PLCPrint(2, "Container name: " .. name)
    local itemCount = Junk.CountFilteredItems(container)
    local addParentheses = MCMGet("add_parentheses")
    local capitalize = MCMGet("capitalize")
    local shouldAppend = MCMGet("append")
    local shouldDisplayNumberOfItems = MCMGet("display_number_of_items")
    local displayCountIfEmpty = MCMGet("if_empty")

    local label = CreateLabel(itemCount, shouldDisplayNumberOfItems, displayCountIfEmpty, addParentheses, capitalize)
    if shouldPadLabel and label ~= "" then -- and shouldDisplayNumberOfItems and itemCount ~= 0 then
        label = LabelString.PadString(label, 58, originalName)
    end

    PLCPrint(3, "Label: " .. label)

    local entity = VCHelpers.Object:GetEntity(container)
    if entity ~= nil then
        if label ~= "" then
            local newDisplayName
            if shouldAppend or shouldPadLabel then
                newDisplayName = originalName .. " " .. label
            else
                newDisplayName = label .. " " .. originalName
            end
            local labeledHandle = GetLabeledHandle(entity)
            Ext.Loca.UpdateTranslatedString(labeledHandle, newDisplayName)
            -- Send to clients so that they can also update the label (won't work on multiplayer otherwise)
            Ext.Net.BroadcastMessage("PLC_UpdateLabel",
            Ext.Json.Stringify({ handle = labeledHandle, newLabel = newDisplayName }))
            entity.DisplayName.NameKey.Handle.Handle = labeledHandle
            entity:Replicate("DisplayName")
        end
    else -- This is a temporary workaround for containers that are not yet loaded
        PLCPrint(2, "Entity is nil")
    end
end

--- After player opens a container, remove the label.
---@param entity EntityHandle
function RemoveLabel(entityHandle)
    local entity = Ext.Entity.Get(entityHandle)
    if entity then
        entity.DisplayName.NameKey.Handle.Handle = RemoveLabelFromHandle(entity.DisplayName.NameKey.Handle.Handle)
        entity:Replicate("DisplayName")
    end
end

return Labeling
