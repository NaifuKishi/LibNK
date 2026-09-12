local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} end

if not LibNK.eventHandlers then LibNK.eventHandlers = {} end
if not LibNK.Events then LibNK.Events = {} end

local internalFunc	= privateVars.internalFunc
local data       	= privateVars.data

local inspectAddonCurrent	= Inspect.Addon.Current
local inspectSystemWatchdog	= Inspect.System.Watchdog
local inspectTimeFrame		= Inspect.Time.Frame
local inspectSystemSecure	= Inspect.System.Secure
local inspectTimeReal		= Inspect.Time.Real

local stringFormat			= string.format

---------- init local variables ---------

local _insecureEvents = {}
local _periodicEvents = {}

local _lastUpdate1, _lastUpdate2

---------- local function block ---------

local function processPeriodic()

	local debugId  
	if nkDebug then debugId = nkDebug.traceStart (inspectAddonCurrent(), "LibNK processPeriodic") end

	local remainingEvents = false

	local currentTime = inspectTimeFrame()
	
	for k, eventDetails in pairs(_periodicEvents) do

		if eventDetails ~= false then -- event will be set to false to stop further processing
			if currentTime - eventDetails.timer > eventDetails.period then
				eventDetails.timer = currentTime
				if eventDetails.func() == true then _periodicEvents[k] = false end

				if eventDetails ~= false and eventDetails.tries ~= nil and eventDetails.tries > 0 then
					eventDetails.currentTries = (eventDetails.currentTries or 0) + 1
					if eventDetails.currentTries >= eventDetails.tries then
						_periodicEvents[k] = false
					else
						remainingEvents = true
					end
				else
					remainingEvents = true
				end

			else
				remainingEvents = true
			end

		end
	end

	if remainingEvents == false then _periodicEvents = {} end

	if nkDebug then nkDebug.traceEnd (inspectAddonCurrent(), "LibNK processPeriodic", debugId) end	

end

local function processInsecure()

	local debugId  
	if nkDebug then debugId = nkDebug.traceStart (inspectAddonCurrent(), "LibNK processInsecure") end

	if inspectSystemSecure() == true then return end

	local remainingEvents = false

	local currentTime = inspectTimeFrame()

	for k, v in pairs(_insecureEvents) do

		if v ~= false then

			if v.timer == nil or v.period == nil then
				local success, err = pcall(v.func)
                if not success then
                    -- Log the error if debugging is enabled
					LibNK.Tools.Error.Display(addonInfo.id, err, FATAL_ERROR_LEVEL)

                    if nkDebug then
                        nkDebug.logEntry(inspectAddonCurrent(), "processInsecure", "Error in insecure event function", err)
                    end
                end
				_insecureEvents[k] = false
			else
				if currentTime - v.timer > v.period then
					local success, err = pcall(v.func)
                    if not success then
                        -- Log the error if debugging is enabled
						LibNK.Tools.Error.Display(addonInfo.id, err, FATAL_ERROR_LEVEL)
                        if nkDebug then
                            nkDebug.logEntry(inspectAddonCurrent(), "processInsecure", "Error in insecure event function", err)
                        end
                    end
					_insecureEvents[k] = false
				else
					remainingEvents = true
				end
			end
		end
	end 

	if remainingEvents == false then _insecureEvents = {} end

	if nkDebug then nkDebug.traceEnd (inspectAddonCurrent(), "LibNK processInsecure", debugId) end	

end

local _eventsS1Index = 1
local _eventsRemIndex = 1

local function updateHandler()

	-- run always

	internalFunc.coRoutinesProcess()
	--internalFunc.processFX()
	processPeriodic()
		
	local _curTime = inspectTimeReal()

	local thisWatchDog = inspectSystemWatchdog()
	
	-- run every 1 second
	
	if (_lastUpdate2 == nil or _curTime - _lastUpdate2 >= 1) then
	
		if thisWatchDog >= 0.1 and _eventsS1Index == 1 then
			--internalFunc.processMap()
			_eventsS1Index = 2
		end
		
		if thisWatchDog >= 0.1 and _eventsS1Index == 2 then
			--internalFunc.checkShard()
			_eventsS1Index = 3
		end
		
		if thisWatchDog >= 0.1 and _eventsS1Index == 3 then
			--internalFunc.uiCheckTooltips()
			_eventsS1Index = 1
		end
		
		_lastUpdate2 = _curTime
	end
	
	-- The 0.1 s round-robin drove processAbilityCooldowns / processItemCooldowns.
	-- Both live in cooldown/, which this library does not carry: cooldowns move to
	-- LibCooldown. The third slot was already commented out in LibEKL.
	
	-- run if there's processor time remaining
	
	if thisWatchDog >= 0.1 and _eventsRemIndex == 1 then
		processInsecure()
		_eventsRemIndex = 2
	end
	
	if thisWatchDog >= 0.1 and _eventsRemIndex == 2 then		
		_eventsRemIndex = 1
	end
	
	-- The performance queue (tools/performance.lua) had no consumer in nkUI,
	-- LibMap or LibQB and is not carried over.

end

---------- library public function block ---------

function LibNK.Events.AddPeriodic(func, period, tries) -- period is in seconds; tries = nil or 0 means infinite
	local uuid = LibNK.Tools.UUID()
	_periodicEvents[uuid] = { func = func, timer = inspectTimeFrame(), period = (period or 0), tries = (tries or 0), currentTries = 0 }
	return uuid
end

function LibNK.Events.AddInsecure(func, timer, period)
	local uuid = LibNK.Tools.UUID ()
	_insecureEvents[uuid] = {func = func, timer = timer, period = period }
	return uuid
end

function LibNK.Events.RemoveInsecure(id) _insecureEvents[id] = false end

function LibNK.Events.CheckEvents (name, init) -- radial muss umgebaut werden, dann kann diese function internalFunc gemacht werden
	if LibNK.eventHandlers[name] == nil and init ~= false then
		LibNK.eventHandlers[name] = {}
		LibNK.Events[name] = {}
	elseif init ~= false then
		LibNK.Tools.Error.Display (addonInfo.identifier, stringFormat("Duplicate name '%s' found!", name), 1)
		return false
	end
	
	return true
end

---------- addon internalFunc function block ---------

function internalFunc.deRegisterEvents (name)
  if LibNK.eventHandlers[name] ~= nil then
    LibNK.eventHandlers[name] = nil
    LibNK.Events[name] = nil
  end
end

-------------------- EVENTS --------------------

Command.Event.Attach(Event.System.Update.Begin, updateHandler, "LibNK.system.updateHandler")