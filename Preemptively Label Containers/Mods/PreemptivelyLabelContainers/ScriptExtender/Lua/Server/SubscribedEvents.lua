local function SubscribeToEvents()
  if JsonConfig.GENERAL.enabled == true then
    Utils.DebugPrint(2, "Subscribing to events with JSON config: " .. Ext.Json.Stringify(JsonConfig, { Beautify = true }))

    Ext.Osiris.RegisterListener("GainedControl", 1, "after", EHandlers.OnGainedControl)

    Ext.Osiris.RegisterListener("TimerFinished", 1, "after", EHandlers.OnTimerFinished)

    if JsonConfig.FEATURES.label.simulate_controller then
      -- Keeps track of opened containers
      Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
      Ext.Osiris.RegisterListener("UseFinished", 3, "before", EHandlers.OnUseEnded)
    end
  end
end

return {
  SubscribeToEvents = SubscribeToEvents
}
