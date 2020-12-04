local garages = nil

Citizen.CreateThread(function()
    garages = LoadRemoteObject('garages')
end)

RegisterCommand('yu', function()
    print(garages.getAmountOfGarages())
    print(garages.getMyself(23)) -- 1 frame problem
    print(garages.getGarages('"lol"'))

    print("Begin big calculus")
    print(garages.bigCalculus())
    print("ended")
end)