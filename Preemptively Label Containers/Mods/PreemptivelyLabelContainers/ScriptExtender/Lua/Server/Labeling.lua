Labeling = {}

Labeling.EMPTY_STRING_HANDLE = "h823595e6g550fg4614gb1ddgdcd323bb4c69"


function IsCorpse(object)
    -- TODO: add knocked out check
    return Osi.IsInPartyWith(object, Osi.GetHostCharacter()) == 0 and GetInventory(object, true, true) ~= nil and
        Osi.IsDead(object) == 1
end

function IsLootable(object)
    return Osi.IsContainer(object) or IsCorpse(object)
end

-- Function to check if the container is empty and change its name
-- TODO: object must not be in EHandlers.opened_containers. If it is, call RemoveEmptyName
function CheckAndRenameEmptyContainer(object)
    -- TODO: IsDead or knocked out ()
    local shouldLabelOwned = (Osi.QRY_CrimeItemHasNPCOwner(object) == 0) or JsonConfig.FEATURES.label.owned_containers

    if IsLootable(object) and shouldLabelOwned then
        SetNewLabel(object)
    end
end

-- Function to pad a string with spaces to match a specified width
---@param str string
---@param width number
---@return string
function PaddedString(str, width)
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

-- Function to create a label based on the item count
local function CreateLabel(count, displayItemCount)
    if displayItemCount then
        return "(" .. count .. ")"
    elseif count == 0 then
        return AddParentheses(Ext.Loca.GetTranslatedString(Labeling.EMPTY_STRING_HANDLE))
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

    local shouldAlignRight = JsonConfig.FEATURES.label.align_right
    local shouldSimulateController = JsonConfig.FEATURES.label.simulate_controller
    local shouldDisplayNumberOfItems = JsonConfig.FEATURES.label.display_number_of_items

    -- Strip existing count or "Empty" from the name
    -- local baseName = name:gsub("%s*%(%d+%)", ""):gsub("%s*%(Empty%)", "")

    -- Append the new count or "Empty" label
    -- TODO: pad (Empty) with spaces to match the width of the UI. This will be a bit tricky since the font isn't monospace, but it should be doable.
    -- We can add the number of spaces until the right edge minus the width of the baseName.
    -- local paddedBaseName = PaddedString(baseName, 54)


    local label = CreateLabel(itemCount, shouldDisplayNumberOfItems)
    if shouldSimulateController and shouldDisplayNumberOfItems and count ~= 0 then
        label = PaddedString(label, 53)
    end

    local entity = GetEntity(container)
    if entity ~= nil then
        if label ~= "" then
            local newDisplayName = shouldAlignRight and objectNameHandle .. " " .. label or
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
function RemoveEmptyName(entity)
    entity.DisplayName.Name = ""
    entity:Replicate("DisplayName")
end

return Labeling
