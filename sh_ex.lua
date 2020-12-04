local IS_SERVER = IsDuplicityVersion()

if IS_SERVER then
    local remoteObject = CreateRemoteObject('ro')

    remoteObject.getLocations = function(source)
        return { vector3(0.0, 0.0, 0.0), vector3(1.0, 1.0, 1.0), vector3(2.0, 2.0, 2.0) }
    end

    remoteObject.multiply = function(source, a, b)
        return a * b
    end

    remoteObject.bigCalculus = function(source)
        for i = 1, 20 do
            Wait(100)
        end
        return 'done'
    end
else
    local remoteObject = nil

    Citizen.CreateThread(function()
        remoteObject = LoadRemoteObject('ro')
        print(remoteObject.getLocations())   --> table:XXX
        print(remoteObject.bigCalculus())    --> done
        print(remoteObject.multiply(2, 3))   --> 6
    end)
end