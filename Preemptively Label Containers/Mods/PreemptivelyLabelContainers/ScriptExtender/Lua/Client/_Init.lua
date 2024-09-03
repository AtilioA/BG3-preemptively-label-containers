Ext.RegisterNetListener("PLC_UpdateLabel", function(call, payload)
    local data = Ext.Json.Parse(payload)
    local handle = data.handle
    local newLabel = data.newLabel

    Ext.Loca.UpdateTranslatedString(handle, newLabel)
end)
