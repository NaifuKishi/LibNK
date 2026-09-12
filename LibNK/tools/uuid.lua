local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} end
if not LibNK.Tools then LibNK.Tools = {} end

local mathRandom    = math.random
local stringGSub    = string.gsub
local stringFormat  = string.format

-- Generates a UUID (Universally Unique Identifier).
-- @return A string representing a UUID.
function LibNK.Tools.UUID()

    local function generateUuid()
        local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

        return stringGSub(template, '[xy]', function(c)
            local v = (c == 'x') and mathRandom(0, 0xf) or mathRandom(8, 0xb)
            return stringFormat('%x', v)
        end)
    end

    return generateUuid()
end