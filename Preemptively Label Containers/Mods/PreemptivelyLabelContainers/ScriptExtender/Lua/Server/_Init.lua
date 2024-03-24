Ext.Require("Server/Config.lua")
Ext.Require("Server/Helpers/Junk.lua")
Ext.Require("Server/Helpers/Dice.lua")
Ext.Require("Server/Helpers/LabelString.lua")
Ext.Require("Server/Helpers/Loot.lua")
Ext.Require("Server/Helpers/Inventory.lua")
Ext.Require("Server/Labeling.lua")
Ext.Require("Server/EventHandlers.lua")

MOD_UUID = "15230bba-a3ab-4352-92f6-1c4c86d2a1e3"
local MODVERSION = Ext.Mod.GetMod(MOD_UUID).Info.ModVersion

if MODVERSION == nil then
    Utils.DebugPrint(0, "loaded (version unknown)")
else
    -- Remove the last element (build/revision number) from the MODVERSION table
    table.remove(MODVERSION)

    local versionNumber = table.concat(MODVERSION, ".")
    Utils.DebugPrint(0, "version " .. versionNumber .. " loaded")
end

local EventSubscription = Ext.Require("Server/SubscribedEvents.lua")
EventSubscription.SubscribeToEvents()
