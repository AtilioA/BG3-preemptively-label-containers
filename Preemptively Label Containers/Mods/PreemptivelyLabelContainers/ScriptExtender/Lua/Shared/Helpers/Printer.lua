PLCPrinter = VolitionCabinetPrinter:New { Prefix = "Preemptively Label Containers", ApplyColor = true, DebugLevel = MCMGet("debug_level") }

-- Update the Printer debug level when the setting is changed, since the value is only used during the object's creation
Ext.RegisterNetListener("MCM_Saved_Setting", function(call, payload)
    local data = Ext.Json.Parse(payload)
    if not data or data.modGUID ~= ModuleUUID or not data.settingId then
        return
    end

    if data.settingId == "debug_level" then
        PLCDebug(0, "Setting debug level to " .. data.value)
        PLCPrinter.DebugLevel = data.value
    end
end)

function PLCPrint(debugLevel, ...)
    PLCPrinter:SetFontColor(0, 255, 255)
    PLCPrinter:Print(debugLevel, ...)
end

function PLCTest(debugLevel, ...)
    PLCPrinter:SetFontColor(100, 200, 150)
    PLCPrinter:PrintTest(debugLevel, ...)
end

function PLCDebug(debugLevel, ...)
    PLCPrinter:SetFontColor(200, 200, 0)
    PLCPrinter:PrintDebug(debugLevel, ...)
end

function PLCWarn(debugLevel, ...)
    PLCPrinter:SetFontColor(255, 100, 50)
    PLCPrinter:PrintWarning(debugLevel, ...)
end

function PLCDump(debugLevel, ...)
    PLCPrinter:SetFontColor(190, 150, 225)
    PLCPrinter:Dump(debugLevel, ...)
end

function PLCDumpArray(debugLevel, ...)
    PLCPrinter:DumpArray(debugLevel, ...)
end
