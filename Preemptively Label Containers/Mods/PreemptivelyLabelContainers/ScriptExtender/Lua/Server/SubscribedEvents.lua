local function SubscribeToEvents()
  if JsonConfig.GENERAL.enabled == true then
    Utils.DebugPrint(2, "Subscribing to events with JSON config: " .. Ext.Json.Stringify(JsonConfig, { Beautify = true }))

    Ext.Osiris.RegisterListener("GainedControl", 1, "after", EHandlers.OnGainedControl)

    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EHandlers.OnTimerFinished)

    Ext.Osiris.RegisterListener("MovedFromTo", 4, "before", EHandlers.OnMovedFromTo)

    -- if JsonConfig.FEATURES.label.simulate_controller then
    Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
    Ext.Osiris.RegisterListener("UseFinished", 3, "before", EHandlers.OnUseEnded)

    Ext.Osiris.RegisterListener("RequestCanLoot", 2, "after", EHandlers.OnRequestCanLoot)
    Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before", EHandlers.OnCharacterLootedCharacter)
    Ext.Osiris.RegisterListener("Died", 1, "before", EHandlers.OnCharacterDied)
  end
end

return {
  SubscribeToEvents = SubscribeToEvents
}
