local garages = CreateRemoteObject('garages')

garages.getGarages = function(source)
    return { vector3(0.0, 0.0, 0.0), vector3(1.0, 1.0, 1.0), vector3(2.0, 2.0, 2.0) }
end

garages.getAmountOfGarages = function(source)
    return 3
end

garages.getMyself = function(source, arg)
    return arg
end

garages.bigCalculus = function(source)
    for i = 1, 10 do
        Wait(100)
    end
    return source
end
