function FilterOutIgnoredItems(items)
    local filteredItems = {}
    for _, item in ipairs(items) do
        if item.TemplateName and not IgnoredItems[item.TemplateName] then
            -- If the item's template name is not in the ignored items list
            table.insert(filteredItems, item)
        end
    end
    return filteredItems
end

function CountFilteredItems(object)
    local items = VCHelpers.Inventory:GetInventory(object)

    -- TODO: filter with user-defined lists (with default lists for junk, rotten, etc.)
    local filteredItems = FilterOutIgnoredItems(items)

    return #filteredItems
end
