local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} else return end
if not LibNK.manager then LibNK.UI = {} end

if not LibNK.eventHandlers then LibNK.eventHandlers = {} end
if not LibNK.Events then LibNK.Events = {} end
if not LibNK.internal then LibNK.internal = {} end -- sobald nkRadial umgebaut ist das hier komplett auf internal umbauen

privateVars.internalFunc = {}
privateVars.data = {}
privateVars.oFuncs = {}

local internalFunc  = privateVars.internalFunc
local data          = privateVars.data

---------- init local variables ---------

local _libInit = false

---------- local function block ---------

local function settingsHandler(_, addon)
	
	if _libInit == true then return end
	
	if LibNK.Events.CheckEvents ("LibNK.internal", true) == false then return nil end

    LibNK.UI.setupBoundCheck()

	LibNK.UI.registerFont(addonInfo.id, "Montserrat", "fonts/Montserrat-Regular.ttf")
	LibNK.UI.registerFont(addonInfo.id, "MontserratSemiBold", "fonts/LibNK-Montserrat-SemiBold.ttf")
	LibNK.UI.registerFont(addonInfo.id, "MontserratBold", "fonts/Montserrat-Bold.ttf")

	LibNK.UI.registerFont(addonInfo.id, "FiraMonoBold", "fonts/FiraMono-Bold.ttf")
	LibNK.UI.registerFont(addonInfo.id, "FiraMonoMedium", "fonts/FiraMono-Medium.ttf")
	LibNK.UI.registerFont(addonInfo.id, "FiraMono", "fonts/FiraMono-Regular.ttf")	

	LibNK.eventHandlers["LibNK.internal"]["gcChanged"], LibNK.Events["LibNK.internal"]["gcChanged"] = Utility.Event.Create(addonInfo.identifier, "LibNK.internal.gcChanged")

	LibNK.Events.CheckEvents ("LibNK.Map", true)
	LibNK.Events.CheckEvents ("LibNK.waypoint", true)
	
	LibNK.eventHandlers["LibNK.Map"]["add"], LibNK.Events["LibNK.Map"]["add"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.mapAdd")
	LibNK.eventHandlers["LibNK.Map"]["change"], LibNK.Events["LibNK.Map"]["change"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.mapChange")
	LibNK.eventHandlers["LibNK.Map"]["remove"], LibNK.Events["LibNK.Map"]["remove"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.mapRemove")
	LibNK.eventHandlers["LibNK.Map"]["coord"], LibNK.Events["LibNK.Map"]["coord"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.mapCoord")	
	LibNK.eventHandlers["LibNK.Map"]["zone"], LibNK.Events["LibNK.Map"]["zone"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.mapZone")
	LibNK.eventHandlers["LibNK.Map"]["shard"], LibNK.Events["LibNK.Map"]["shard"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.mapShard")
	LibNK.eventHandlers["LibNK.Map"]["unitAdd"], LibNK.Events["LibNK.Map"]["unitAdd"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.unitAdd")
	LibNK.eventHandlers["LibNK.Map"]["unitChange"], LibNK.Events["LibNK.Map"]["unitChange"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.unitChange")
	LibNK.eventHandlers["LibNK.Map"]["unitRemove"], LibNK.Events["LibNK.Map"]["unitRemove"] = Utility.Event.Create(addonInfo.identifier, "LibNK.Map.unitRemove")
	LibNK.eventHandlers["LibNK.waypoint"]["change"], LibNK.Events["LibNK.waypoint"]["change"] = Utility.Event.Create(addonInfo.identifier, "LibNK.waypoint.change")
	LibNK.eventHandlers["LibNK.waypoint"]["add"], LibNK.Events["LibNK.waypoint"]["add"] = Utility.Event.Create(addonInfo.identifier, "LibNK.waypoint.add")
	LibNK.eventHandlers["LibNK.waypoint"]["remove"], LibNK.Events["LibNK.waypoint"]["remove"] = Utility.Event.Create(addonInfo.identifier, "LibNK.waypoint.remove")

	_libInit = true
		
end

-------------------- STARTUP EVENTS --------------------

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, settingsHandler, "LibNK.settingsHandler.SavedVariables.Load.End")