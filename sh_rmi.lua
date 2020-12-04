-- @desc Synchronous remote method invocation.
-- @author Elio
-- @version 1.0

local IS_SERVER = IsDuplicityVersion()
local EVENT_PREFIX = 'rmi:'
local DEBUG = true

-- Shared part
local tse = TriggerServerEvent
local tce = TriggerClientEvent

local function netEvent(name, func)
	RegisterNetEvent(name)
	AddEventHandler(name, func)
end

local function event(name, func)
	AddEventHandler(name, func)
end

local function log(name, text)
	if DEBUG then
		Citizen.Trace('^1' .. name .. ': ^0' .. text .. '\n')
	end
end

if IS_SERVER then
    -- Server part
    local function registerMethod(ro, key, func)
        local eventName = ro.prefix .. key .. ':'

        if type(func) == 'function' then        
            netEvent(eventName .. 'request', function(...)
                tce(eventName .. 'send', source, func(source, ...)) -- Keep in mind I can't do all the magic for you
            end)

            log('rmi-info', 'Registered a new method: "' .. eventName .. '".')
            ro.functions[key] = eventName .. 'send'
        else
            log('rmi-error', 'You tried to register something that isn\'t a method: "' .. eventName .. '".')
        end
    end

    -- @desc Create a new remote object that can be loaded by a client.
    -- @param name name of the object
    -- @return the remote object
    function CreateRemoteObject(name)
        -- Initialiaze the object
        local ro = {}
        ro.prefix = EVENT_PREFIX .. name .. ':'
        ro.functions = {}
        setmetatable(ro, { __newindex = registerMethod })

        -- Make it ready to be sent to a client
        netEvent(ro.prefix .. 'get', function()
            tce(ro.prefix .. 'set', source, ro.functions)
        end)

        return ro
    end
else
    -- Client part
    local function registerMethods(ro, functions)
        for key, event in pairs(functions) do
            ro[key] = function(...)
                local eventName = ro.prefix .. key .. ':'
                local p = promise.new()

                log('rmi-info', 'New method called : "' .. eventName .. '".')
                tse(eventName .. 'request', ...)

                netEvent(event, function(args)
                    p:resolve(args)
                end)

                return Citizen.Await(p)
            end
        end
    end

    -- @desc Get a remote object created by the server.
    -- @param name name of the object
    -- @return the remote object
    function LoadRemoteObject(name)
        local ro = {}
        ro.prefix = EVENT_PREFIX .. name .. ':'

        local p = promise.new()

        tse(ro.prefix .. 'get')

        netEvent(ro.prefix .. 'set', function(functions)
            registerMethods(ro, functions)
            p:resolve()
        end)

        Citizen.Await(p)

        return ro
    end
end
