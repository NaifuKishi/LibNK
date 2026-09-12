local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} end
if not LibNK.Tools then LibNK.Tools = {} end

LibNK.Tools.Lang = {}

---------- init local variables ---------

local inspectSystemLanguage = Inspect.System.Language

local stringLower = string.lower

-- Language constants
local GERMAN_LANGUAGE = 'German'
local FRENCH_LANGUAGE = 'French'
local RUSSIAN_LANGUAGE = 'Russian'
local DEFAULT_LANGUAGE = 'EN'

local GERMAN_SHORT = 'DE'
local FRENCH_SHORT = 'FR'
local RUSSIAN_SHORT = 'RU'

-- ========== LANGUAGE HANDLING ========== --

-- Gets the current language.
-- @return The current language.
function LibNK.Tools.Lang.GetLanguage()
    -- Check if LibNKSetup is nil or if the language is not set
    if LibNKSetup == nil then
        return inspectSystemLanguage()
    elseif LibNKSetup.language == nil then
        return inspectSystemLanguage()
    else
        -- Return the language set in LibNKSetup
        return LibNKSetup.language
    end
end

-- Gets the short form of a language.
-- @param language The language to get the short form for.
-- @return The short form of the language.
local function getLanguageShort(language)
    -- Determine the short form of the language
    if language == GERMAN_LANGUAGE then
        return GERMAN_SHORT
    elseif language == FRENCH_LANGUAGE then
        return FRENCH_SHORT
    elseif language == RUSSIAN_LANGUAGE then
        return RUSSIAN_SHORT
    else
        return DEFAULT_LANGUAGE
    end
end

-- Gets the short form of the current language.
-- @return The short form of the current language.
function LibNK.Tools.Lang.GetLanguageShort()
    -- Get the short form of the current language
    return getLanguageShort(LibNK.Tools.Lang.GetLanguage())
end

-- Sets the current language.
-- @param language The language to set.
function LibNK.Tools.Lang.SetLanguage(language)
    -- Initialize LibNKSetup if it is nil
    if LibNKSetup == nil then LibNKSetup = {} end
    -- Set the language in LibNKSetup
    LibNKSetup.language = language
    -- Override the inspectSystemLanguage function to return the set language
    inspectSystemLanguage = function() return LibNKSetup.language end
end

-- Resets the current language to the system language.
function LibNK.Tools.Lang.ResetLanguage()
    -- Initialize LibNKSetup if it is nil
    if LibNKSetup == nil then LibNKSetup = {} end
    -- Reset the language in LibNKSetup to nil
    LibNKSetup.language = nil
end