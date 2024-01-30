Labeling = {}

Labeling.EMPTY_STRING_HANDLE = "h823595e6g550fg4614gb1ddgdcd323bb4c69"


function Labeling.LabelNearbyContainers()
    local nearbyContainers = GetNearbyCharactersAndItems(Osi.GetHostCharacter(), JsonConfig.FEATURES.radius, true, true)
    Utils.DebugPrint(3, "Nearby items: " .. #nearbyContainers)

    for _, member in ipairs(nearbyContainers) do
        local isNewOrReopened = not EHandlers.processed_objects[member.Guid] or EHandlers.recently_closed[member.Guid]
        if isNewOrReopened then
            Utils.DebugPrint(2, "Processing object: " .. member.Guid)
            CheckAndRenameEmptyContainer(member.Guid)
            EHandlers.processed_objects[member.Guid] = true
            EHandlers.recently_closed[member.Guid] = nil
        else
            -- Utils.DebugPrint(2, "Not processing container: " .. member.Guid)
        end
    end
end

function IsCorpse(object)
    -- TODO: add knocked out check
    return GetInventory(object, true, true) ~= nil and Osi.IsDead(object) == 1
end

function IsLootable(object)
    return (Osi.IsContainer(object) == 1) or IsCorpse(object)
end

-- Function to check if the container is empty and change its name
-- TODO: object must not be in EHandlers.all_opened_containers. If it is, call RemoveEmptyName
function CheckAndRenameEmptyContainer(object)
    local shouldLabelOwned = (Osi.QRY_CrimeItemHasNPCOwner(object) == 0) or JsonConfig.FEATURES.labeling
    .owned_containers
    local shouldRemoveFromOpened = JsonConfig.FEATURES.labeling.remove_from_opened

    if IsLootable(object) and shouldLabelOwned then
        -- This will also remove numeric labels (i.e., not only Empty labels)
        if shouldRemoveFromOpened and EHandlers.all_opened_containers[object] then
            Utils.DebugPrint(2, "Removing label for: " .. object)
            -- RemoveLabel(object)
        else
            Utils.DebugPrint(2, "Setting label for: " .. object)
            SetNewLabel(object)
        end
    end
end

-- Function to pad a string with spaces to match a specified width
---@param str string
---@param width number
---@return string
function PadString(str, width)
    -- TODO: pad (Empty) with spaces to match the width of the UI. This will be a bit tricky since the font isn't monospace, but it should be doable.
    -- We can add the number of spaces until the right edge minus the width of the baseName.
    local strWidth = string.len(str)
    if strWidth >= width then
        return str
    end

    local padding = width - strWidth
    -- Remove one extra for each uppercase letter in the string
    padding = padding - string.len(str:gsub("%u", ""))
    local paddedStr = string.rep(" ", padding) .. str
    return paddedStr
end

--- Add parentheses around a string if it does not already have them
function AddParentheses(str)
    if string.match(str, "%(.*%)") then
        return str
    else
        return "(" .. str .. ")"
    end
end

-- Remove parentheses around a string if it has them
function RemoveParentheses(str)
    return string.gsub(str, "%s*%(%s*(.*)%s*%)", "%1")
end

function Capitalize(str)
    return str:gsub("^%l", string.upper)
end

function Lowercase(str)
    return str:gsub("^%u", string.lower)
end

-- Function to create a label based on the item count
local function CreateLabel(count, displayItemCount, addParentheses, capitalize)
    if displayItemCount then
        return "(" .. count .. ")"
    elseif count == 0 then
        local translatedString = RemoveParentheses(Ext.Loca.GetTranslatedString(Labeling.EMPTY_STRING_HANDLE))

        if capitalize then
            translatedString = Capitalize(translatedString)
        else
            translatedString = Lowercase(translatedString)
        end

        if addParentheses then
            translatedString = AddParentheses(translatedString)
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
    local shouldAppend = JsonConfig.FEATURES.label.appended
    local shouldSimulateController = JsonConfig.FEATURES.label.simulate_controller
    local shouldDisplayNumberOfItems = JsonConfig.FEATURES.label.display_number_of_items


    local label = CreateLabel(itemCount, shouldDisplayNumberOfItems, addParentheses, capitalize)
    if shouldSimulateController and shouldDisplayNumberOfItems and count ~= 0 then
        label = PadString(label, 53)
    end

    Utils.DebugPrint(2, "Label: " .. label)

    local entity = GetEntity(container)
    if entity ~= nil then
        if label ~= "" then
            local newDisplayName = shouldAppend and objectNameHandle .. " " .. label or
                label .. " " .. objectNameHandle
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
function RemoveLabel(entity)
    Utils.DebugPrint(2, "Removing label for: " .. entity)
    entity.DisplayName.Name = ""
    entity:Replicate("DisplayName")
end

-- -- Function to remove or adjust the label of a reopened container
-- ---@param container EntityHandle
-- function RemoveLabel(container)
--     local entity = GetEntity(container)
--     if entity ~= nil then
--         local nameWithoutParentheses = RemoveParentheses(entity.DisplayName.Name)
--         entity.DisplayName.Name = nameWithoutParentheses
--         entity:Replicate("DisplayName")
--     else
--         Utils.DebugPrint(2, "Entity is nil")
--     end
-- end


return Labeling
