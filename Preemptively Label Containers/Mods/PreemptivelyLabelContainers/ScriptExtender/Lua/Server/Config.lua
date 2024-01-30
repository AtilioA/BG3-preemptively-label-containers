Config = {}

FolderName = "PreemptivelyLabelContainers"
Config.configFilePath = "preemptively_label_containers_config.json"

Config.defaultConfig = {
    GENERAL = {
        enabled = true, -- Toggle the mod on/off
    },
    FEATURES = {
        radius = 6,              -- How far away to look for nearby containers (in meters) (controller search radius is 5m)
        refresh_interval = 500,  -- How often to refresh the list of nearby containers (in milliseconds). Recommendation: set it between 250-2000, higher if you have a weaker CPU. (Labels are always immediately updated after usage.)
        labeling = {
            owned_containers = true, -- Label containers owned by others (the ones that show a red highlight)
            remove_from_opened = false, -- Remove the label from containers that are opened by the player (good for controller users)
        },
        label = {
            add_parentheses = true,          -- Make sure the label is surrounded by parentheses
            appended = true,                 -- Adds the label after the container's name (false = prepends the label)
            simulate_controller = false,     -- Simulate controller '(Empty)' label seen in controller UI. Will look bad in KB/M UI.
            display_number_of_items = false, -- Display the number of items in the container
        },
        -- TODO: refactor this to accept user lists
        filter = {
            rotten = true,       -- Ignore rotten items when counting items in containers
            junk = true,         -- TODO: Ignore junk items when counting items in containers
        },
        perception_check_dc = 0, -- Perception check DC to label a container (0 = always succeed)
    },
    DEBUG = {
        level = 0, -- 0 = no debug, 1 = minimal, 2 = verbose logs
        always_relabel = false, -- Always try to label containers, even if they are already labeled
    }
}


function Config.GetModPath(filePath)
    return FolderName .. '/' .. filePath
end

-- Load a JSON configuration file and return a table or nil
function Config.LoadConfig(filePath)
    local configFileContent = Ext.IO.LoadFile(Config.GetModPath(filePath))
    if configFileContent and configFileContent ~= "" then
        Utils.DebugPrint(1, "Loaded config file: " .. filePath)
        return Ext.Json.Parse(configFileContent)
    else
        Utils.DebugPrint(1, "File not found: " .. filePath)
        return nil
    end
end

-- Save a config table to a JSON file
function Config.SaveConfig(filePath, config)
    local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
    Ext.IO.SaveFile(Config.GetModPath(filePath), configFileContent)
end

function Config.UpdateConfig(existingConfig, defaultConfig)
    local updated = false

    for key, newValue in pairs(defaultConfig) do
        local oldValue = existingConfig[key]

        if oldValue == nil then
            -- Add missing keys from the default config
            existingConfig[key] = newValue
            updated = true
            Utils.DebugPrint(1, "Added new config option:", key)
        elseif type(oldValue) ~= type(newValue) then
            -- If the type has changed...
            if type(newValue) == "table" then
                -- ...and the new type is a table, place the old value in the 'enabled' key
                existingConfig[key] = { enabled = oldValue }
                for subKey, subValue in pairs(newValue) do
                    if existingConfig[key][subKey] == nil then
                        existingConfig[key][subKey] = subValue
                    end
                end
                updated = true
                Utils.DebugPrint(1, "Updated config structure for:", key)
            else
                -- ...otherwise, just replace with the new value
                existingConfig[key] = newValue
                updated = true
                Utils.DebugPrint(1, "Updated config value for:", key)
            end
        elseif type(newValue) == "table" then
            -- Recursively update for nested tables
            if Config.UpdateConfig(oldValue, newValue) then
                updated = true
            end
        end
    end

    -- Remove deprecated keys
    for key, _ in pairs(existingConfig) do
        if defaultConfig[key] == nil then
            -- Remove keys that are not in the default config
            existingConfig[key] = nil
            updated = true
            Utils.DebugPrint(1, "Removed deprecated config option:", key)
        end
    end

    return updated
end

function Config.LoadJSONConfig()
    local jsonConfig = Config.LoadConfig(Config.configFilePath)
    if not jsonConfig then
        jsonConfig = Config.defaultConfig
        Config.SaveConfig(Config.configFilePath, jsonConfig)
        Utils.DebugPrint(1, "Default config file loaded.")
    else
        if Config.UpdateConfig(jsonConfig, Config.defaultConfig) then
            Config.SaveConfig(Config.configFilePath, jsonConfig)
            Utils.DebugPrint(1, "Config file updated with new options.")
        else
            Utils.DebugPrint(1, "Config file loaded.")
        end
    end

    return jsonConfig
end

JsonConfig = Config.LoadJSONConfig()

return Config
