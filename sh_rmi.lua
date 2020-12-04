-- @desc Synchronous remote method invocation.
-- @author Elio
-- @version 1.0

local IS_SERVER = IsDuplicityVersion()
local EVENT_PREFIX = 'rmi:'
local DEBUG = true

local tse = TriggerServerEvent
local tce = TriggerClientEvent
local event = AddEventHandler

local function netEvent(name, func)
	RegisterNetEvent(name)
	AddEventHandler(name, func)
end

local function log(name, text)
	if DEBUG then
		Citizen.Trace('^1' .. name .. ': ^0' .. text .. '\n')
	end
end

if IS_SERVER then
    local function registerMethod(ro, key, func)
        local eventName = ro.prefix .. key .. ':'

        if type(func) == 'function' then   
            log('rmi-info', 'Registered a new method: "' .. eventName .. '".')

            ro.functions[key] = eventName .. 'send'

            netEvent(eventName .. 'request', function(...)
                tce(eventName .. 'send', source, func(source, ...))
            end)
        else
            log('rmi-error', 'You tried to register something that isn\'t a method: "' .. eventName .. '".')
        end
    end

    -- @desc Create a new remote object that can be loaded by a client.
    -- @param name name of the object
    -- @return the remote object
    function CreateRemoteObject(name)
        local ro = {}
        ro.prefix = EVENT_PREFIX .. name .. ':'
        ro.functions = {}

        setmetatable(ro, { __newindex = registerMethod })

        netEvent(ro.prefix .. 'get', function()
            tce(ro.prefix .. 'set', source, ro.functions)
        end)

        return ro
    end
else
    local function registerMethods(ro, functions)
        ro.handlers = {}
        for key, event in pairs(functions) do
            
            netEvent(event, function(...) -- Register the event one time
                ro.handlers[key](...)
            end)

            ro[key] = function(...)
                local eventName = ro.prefix .. key .. ':'
                local p = promise.new()

                log('rmi-info', 'New method called : "' .. eventName .. '".')
                tse(eventName .. 'request', ...)

                ro.handlers[key] = function(args)
                    p:resolve(args)
                end

                return Citizen.Await(p)
            end
        end
    end

    -- @desc Get a remote object created by the server.
    -- @param name name of the object
    -- @return the remote object
    function LoadRemoteObject(name)
        local p = promise.new()
        local ro = {}
        ro.prefix = EVENT_PREFIX .. name .. ':'

        tse(ro.prefix .. 'get')

        netEvent(ro.prefix .. 'set', function(functions)
            registerMethods(ro, functions)
            p:resolve(ro)
        end)

        return Citizen.Await(p)
    end
end
