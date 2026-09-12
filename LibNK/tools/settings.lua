local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} end
if not LibNK.Tools then LibNK.Tools = {} end

LibNK.Tools.Settings = {}

-- ========== SETTINGS TOOLS ========== --

-- Table type constant.
local TABLE_TYPE = 'table'

-- Checks if a value is a table.
-- @param value The value to check.
-- @return true if the value is a table, false otherwise.
local function isTable(value)
    -- Check if the value is a table
    return type(value) == TABLE_TYPE
end

-- Updates the current settings with the default settings.
-- @param defaultSettings The default settings.
-- @param thisSettings The current settings.
-- @return The updated settings.
function LibNK.Tools.Settings.UpdateSettings(defaultSettings, thisSettings)

    -- Check if the input parameters are tables
    if not isTable(defaultSettings) or not isTable(thisSettings) then
        LibNK.Tools.Error.Display("LibNK.Tools.Settings.UpdateSettings", "defaultSettings and thisSetttings must be a table", 2)
        return thisSettings
    end

    -- Iterate over the default settings
    for key, value in pairs(defaultSettings) do
        -- If the key is not present in the current settings, add it

        if thisSettings[key] == nil then
            thisSettings[key] = value
        -- If both the default and current settings are tables, recursively update the settings
        elseif isTable(value) and isTable(thisSettings[key]) then
            LibNK.Tools.Settings.UpdateSettings(value, thisSettings[key])
        end
    end

    -- Return the updated settings
    return thisSettings

end