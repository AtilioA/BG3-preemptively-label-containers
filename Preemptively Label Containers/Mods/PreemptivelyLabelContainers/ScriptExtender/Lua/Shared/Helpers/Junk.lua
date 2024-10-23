Junk = {}

local ignoredItems = MCM.GetList("ignored_items")
local ignoredItemsCount = 0

-- Create a table for fast ignored items lookup
Junk.IgnoredItemsTable = {}
for ignoredItem, isEnabled in pairs(ignoredItems) do
    if isEnabled then
        Junk.IgnoredItemsTable[ignoredItem] = true
        ignoredItemsCount = ignoredItemsCount + 1
    end
end

PLCPrint(1, "Loaded " .. ignoredItemsCount .. " ignored items")

function Junk.CountFilteredItems(object)
    local items = VCHelpers.Inventory:GetInventory(object)
    local filteredItems = {}

    PLCPrint(2, "Container " ..
        VCHelpers.Loca:GetDisplayName(object) .. " has " .. #items .. " items: " .. Ext.DumpExport(items))

    for _, item in ipairs(items) do
        -- Check if the item's template name is not in the ignored items list
        if not Junk.IgnoredItemsTable[item.TemplateName] then
            PLCPrint(2, "Item " .. item.TemplateName .. " is not ignored")
            table.insert(filteredItems, item)
        else
            PLCPrint(2, "Item " .. item.TemplateName .. " is ignored")
        end
    end

    return #filteredItems
end

return Junk
