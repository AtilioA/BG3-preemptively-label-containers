SubscribedEvents = {}


function SubscribedEvents.SubscribeToEvents()
  if Config:getCfg().GENERAL.enabled == true then
    Utils.DebugPrint(2,
      "Subscribing to events with JSON config: " .. Ext.Json.Stringify(Config:getCfg(), { Beautify = true }))

    Ext.Osiris.RegisterListener("GainedControl", 1, "after", EHandlers.OnGainedControl)

    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EHandlers.OnTimerFinished)

    Ext.Osiris.RegisterListener("MovedFromTo", 4, "before", EHandlers.OnMovedFromTo)

    -- if Config:getCfg().FEATURES.label.simulate_controller then
    Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
    Ext.Osiris.RegisterListener("UseFinished", 3, "before", EHandlers.OnUseEnded)

    Ext.Osiris.RegisterListener("RequestCanLoot", 2, "before", EHandlers.OnRequestCanLoot)
    Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before", EHandlers.OnCharacterLootedCharacter)
    Ext.Osiris.RegisterListener("Died", 1, "before", EHandlers.OnCharacterDied)
  end
end

return SubscribedEvents
