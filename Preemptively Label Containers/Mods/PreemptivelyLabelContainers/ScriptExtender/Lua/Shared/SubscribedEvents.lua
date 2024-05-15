SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
    local function conditionalWrapper(handler)
        return function(...)
            if MCMGet("mod_enabled") then
                handler(...)
            else
                PLCDebug(1, "Event handling is disabled.")
            end
        end
    end

    PLCPrint(2,
        "Subscribing to events with JSON config: " ..
        Ext.Json.Stringify(Mods.BG3MCM.MCMAPI:GetAllModSettings(ModuleUUID), { Beautify = true }))

    Ext.Osiris.RegisterListener("GainedControl", 1, "after", conditionalWrapper(EHandlers.OnGainedControl))
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 1, "after", conditionalWrapper(EHandlers.OnLevelGameplayStarted))

    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", conditionalWrapper(EHandlers.OnTimerFinished))

    Ext.Osiris.RegisterListener("UseStarted", 2, "before", conditionalWrapper(EHandlers.OnUseStarted))
    Ext.Osiris.RegisterListener("UseFinished", 3, "before", conditionalWrapper(EHandlers.OnUseEnded))

    Ext.Osiris.RegisterListener("RequestCanLoot", 2, "before", conditionalWrapper(EHandlers.OnRequestCanLoot))
    Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before",
        conditionalWrapper(EHandlers.OnCharacterLootedCharacter))
    Ext.Osiris.RegisterListener("Died", 1, "before", conditionalWrapper(EHandlers.OnCharacterDied))

    -- Update labels if any settings are changed
    Ext.RegisterNetListener("MCM_Saved_Setting", function(call, payload)
        local data = Ext.Json.Parse(payload)
        if not data or data.modGUID ~= ModuleUUID or not data.settingId then
            return
        end

        Labeling.LabelNearbyContainers()
    end)
end

return SubscribedEvents
