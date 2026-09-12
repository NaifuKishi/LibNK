-- Laedt alle RunOnStartup-Dateien in Manifest-Reihenfolge gegen einen
-- permissiven Rift-Stub. Prueft Ladezeit-Fehler, nicht Laufzeitverhalten.
local function stub(name)
  local t = {}
  setmetatable(t, {
    __index = function(s, k)
      if type(k) ~= "string" then return nil end
      local child = stub(name .. "." .. k)
      rawset(s, k, child)
      return child
    end,
    __call = function(_, ...) return stub(name .. "()") end,
  })
  return t
end
Inspect, Command, Utility, UI, Event, System = stub"Inspect", stub"Command", stub"Utility", stub"UI", stub"Event", stub"System"
dump = function() end
UIParent = stub"UIParent"

local dir = arg[1]
local toc = io.open(dir .. "/RiftAddon.toc"):read("*a")
local body = toc:match("RunOnStartup%s*=%s*{(.-)\n}")
local files = {}
for f in body:gmatch('"([^"]+%.lua)"') do files[#files+1] = f end

local bad = 0
for i = 1, #files do
  local path = dir .. "/" .. files[i]
  local chunk, err = loadfile(path)
  if not chunk then
    print(("LADEFEHLER  %s: %s"):format(files[i], err)); bad = bad + 1
  else
    local ok, e = pcall(chunk, { identifier = "LibNK", toc = {} }, { internalFunc = {}, data = {}, uiElements = {}, events = {} })
    if not ok then print(("AUSFUEHRUNG %s: %s"):format(files[i], tostring(e))); bad = bad + 1 end
  end
end
print(("%d Dateien geladen, %d Fehler"):format(#files, bad))
os.exit(bad == 0 and 0 or 1)
