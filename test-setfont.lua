-- Prueft LibNK.UI.SetFont gegen die echte Implementierung in ui/ui.lua.
--
-- Hintergrund: die Funktion schlug frueher still fehl - unbekannte addonId oder
-- unbekannter Fontname fuehrten wortlos zur Standardschrift. Genau so blieb
-- waehrend der Migration ein ganzer nkUI-Modulumbau unbemerkt entstellt.
-- Sie darf die Ursache jetzt benennen, aber weiterhin niemals werfen.

local function stub(name)
  local t = {}
  setmetatable(t, {
    __index = function(s, k)
      if type(k) ~= "string" then return nil end
      local c = stub(name .. "." .. k); rawset(s, k, c); return c
    end,
    __call = function(_, ...) return stub(name .. "()") end,
  })
  return t
end
Inspect, Command, Utility, UI, Event, System =
  stub"Inspect", stub"Command", stub"Utility", stub"UI", stub"Event", stub"System"
UIParent = stub"UIParent"
dump = function() end

assert(loadfile("LibNK/ui/ui.lua"))({ id = "LibNK", identifier = "LibNK", toc = {} },
  { internalFunc = {}, data = {}, uiElements = {}, events = {} })

-- Meldeweg abfangen
local warnings = {}
LibNK.Tools = LibNK.Tools or {}
LibNK.Tools.Error = { Display = function(src, msg, level)
  warnings[#warnings + 1] = { src = src, msg = msg, level = level }
end }

local function widget()
  local w = { applied = nil, calls = 0 }
  function w:SetFont(addonId, path) self.calls = self.calls + 1; self.applied = path end
  return w
end
local function lastWarning() return warnings[#warnings] end
local function warnCount() return #warnings end

local failed = 0
local function check(label, ok, detail)
  if ok then print("  ok    " .. label)
  else failed = failed + 1; print("  FAIL  " .. label .. (detail and ("  -- " .. detail) or "")) end
end

LibNK.UI.registerFont("nkUI", "MontserratBold", "fonts/Montserrat-Bold.ttf")

print("Fall A - addonId ohne jede Registrierung")
local n0 = warnCount()
local w = widget()
LibNK.UI.SetFont(w, "nkDebug", "MontserratBold")
check("warnt genau einmal", warnCount() == n0 + 1, warnCount() - n0 .. " Warnungen")
check("nennt Quelle, addonId und Font",
  lastWarning().src == "LibNK.UI.SetFont"
  and lastWarning().msg:find("nkDebug", 1, true) ~= nil
  and lastWarning().msg:find("MontserratBold", 1, true) ~= nil,
  lastWarning().msg)
check("Level 3 (WARNING)", lastWarning().level == 3)
check("ruft uiElement:SetFont nicht auf", w.calls == 0)

print("Fall A2 - dieselbe Kombination erneut")
local n1 = warnCount()
LibNK.UI.SetFont(widget(), "nkDebug", "MontserratBold")
check("warnt kein zweites Mal", warnCount() == n1)

print("Fall A3 - dieselbe addonId, anderer Font")
LibNK.UI.SetFont(widget(), "nkDebug", "FiraMono")
check("warnt je Kombination erneut", warnCount() == n1 + 1)

print("Fall B - addonId bekannt, Fontname nicht")
local n2 = warnCount()
local wb = widget()
LibNK.UI.SetFont(wb, "nkUI", "GibtEsNicht")
check("warnt genau einmal", warnCount() == n2 + 1)
check("nennt den fehlenden Fontnamen",
  lastWarning().msg:find("GibtEsNicht", 1, true) ~= nil, lastWarning().msg)
check("reicht kein nil an uiElement:SetFont weiter", wb.calls == 0)

print("Erfolgsfall - bekannter Font")
local n3 = warnCount()
local wg = widget()
LibNK.UI.SetFont(wg, "nkUI", "MontserratBold")
check("setzt den registrierten Pfad", wg.applied == "fonts/Montserrat-Bold.ttf",
  tostring(wg.applied))
check("warnt nicht", warnCount() == n3)

print("Randfaelle - Argumente, die keine Strings sind")
for _, case in ipairs {
  { label = "addonId ist eine Tabelle", id = { id = "nkUI" }, name = "MontserratBold" },
  { label = "addonId ist nil",          id = nil,             name = "MontserratBold" },
  { label = "Fontname ist nil",         id = "nkUI",          name = nil },
  { label = "beide nil",                id = nil,             name = nil },
} do
  local ok, err = pcall(LibNK.UI.SetFont, widget(), case.id, case.name)
  check(case.label .. ": wirft nicht", ok, tostring(err))
end

print("Registrierte Schriftdateien liegen auch wirklich da")
-- Der Fork hat den Pfad umbenannt, die Datei aber nicht: MontserratSemiBold
-- zeigte auf fonts/LibNK-Montserrat-SemiBold.ttf, auf der Platte lag noch
-- LibEKL-... . SetFont findet den Eintrag, reicht ihn weiter und schweigt -
-- die Warnungen oben greifen hier nicht. Sichtbar wurde es erst im Spiel, als
-- die nkClickButton-Beschriftungen als leere Kaesten erschienen.
do
  local main = assert(io.open("LibNK/main.lua")):read("*a")
  local n = 0
  for path in main:gmatch('registerFont%s*%([^,]+,%s*"[^"]+"%s*,%s*"([^"]+)"') do
    n = n + 1
    local fh = io.open("LibNK/" .. path)
    check("vorhanden: " .. path, fh ~= nil)
    if fh then fh:close() end
  end
  check("sechs Schriften registriert", n == 6, n .. " gefunden")
end

print("")
if failed == 0 then print("alle Pruefungen bestanden") else print(failed .. " Pruefung(en) fehlgeschlagen") end
os.exit(failed == 0 and 0 or 1)
