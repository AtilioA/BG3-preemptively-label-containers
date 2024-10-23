Junk = {}

local ignoredItems = MCM.GetList("ignored_items")
local ignoredItemsCount = #ignoredItems
PLCPrint(1, "Loaded " .. ignoredItemsCount .. " ignored items")

-- Create a table for fast ignored items lookup
local ignoredItemsTable = {}
for _, ignoredItem in ipairs(ignoredItems) do
    ignoredItemsTable[ignoredItem] = true
end

function Junk.CountFilteredItems(object)
    local items = VCHelpers.Inventory:GetInventory(object)
    local filteredItems = {}

    for _, item in ipairs(items) do
        -- Check if the item's template name is in the ignored items list
        if not ignoredItemsTable[item.TemplateName] then
            table.insert(filteredItems, item)
        end
    end

    return #filteredItems
end

return Junk
