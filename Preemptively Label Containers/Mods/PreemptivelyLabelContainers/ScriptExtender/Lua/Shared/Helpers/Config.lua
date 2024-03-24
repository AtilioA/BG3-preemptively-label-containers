Config = VCHelpers.Config:New({
  folderName = "PreemptivelyLabelContainers",
  configFilePath = "preemptively_label_containers_config.json",
  defaultConfig = {
    GENERAL = {
        enabled = true, -- Toggle the mod on/off
    },
    FEATURES = {
        radius = 10,                         -- How far away to look for nearby containers (in meters) (controller search radius is 5)
        refresh_interval = 500,              -- How often to refresh the list of nearby containers (in milliseconds). Recommendation: set it between 250-2000, higher if you have a weaker CPU. (Labels are always immediately updated after container usage)
        also_check_for_party_members = true, -- Label containers for all party members (false = only label for the host/active character)
        labeling = {
            always_relabel = true,           -- Skip checks to update containers labels: always regenerate labels even if they are already labeled
            owned_containers = true,         -- Label containers owned by others (the ones that show a red highlight)
            -- remove_from_opened = false, -- Remove the label from containers that are opened by the player (good for controller users) (UNUSED)
            perception_check_dc = 0,         -- Perception check DC to label a container (0 = always succeed)
        },
        label = {
            capitalize = true,           -- Capitalize the label
            add_parentheses = true,      -- Make sure the label is surrounded by parentheses
            append = true,               -- Adds the label after the container's name (false = prepends the label)
            simulate_controller = false, -- Simulate controller '(Empty)' label seen in controller UI search results. Will look bad in KB/M UI.
            display_number_of_items = {
                enabled = false,         -- Display the number of items in the container
                if_empty = true,         -- Show the number of items even if the container is empty
            }
        },
        filters = {
            ignored_items = true, -- Ignore items in the 'ignored_items.json' file
        },
    },
    DEBUG = {
        level = 0, -- 0 = no debug, 1 = minimal, 2 = verbose logs
    },
  },
})

Config:UpdateCurrentConfig()

Config:AddConfigReloadedCallback(function(configInstance)
  ASRBTCPrinter.DebugLevel = configInstance:GetCurrentDebugLevel()
  ASRBTCPrint(0, "Config reloaded: " .. Ext.Json.Stringify(configInstance:getCfg(), { Beautify = true }))
end)
Config:RegisterReloadConfigCommand("plc")
