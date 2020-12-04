local IS_SERVER = IsDuplicityVersion()

if IS_SERVER then
    local garages = CreateRemoteObject('garages')
    local count = 0

    garages.getGarages = function(source)
        return { vector3(0.0, 0.0, 0.0), vector3(1.0, 1.0, 1.0), vector3(2.0, 2.0, 2.0) }
    end

    garages.getCount = function(source)
        count = count + 1
        return count
    end

    garages.bigCalculus = function(source)
        for i = 1, 20 do
            Wait(100)
        end
        return source
    end
else
    local garages = nil

    Citizen.CreateThread(function()
        garages = LoadRemoteObject('garages')
        -- print(garages.getGarages())
        -- print(garages.bigCalculus())
        print(garages.getCount())
        print(garages.getCount())
        print(garages.getCount())
    end)
end