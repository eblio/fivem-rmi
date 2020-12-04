# fivem-rmi
Remote method invocation implemented in LUA for Fivem.

## Description
Allows you to fetch data from the server synchronously and avoid nested callbacks.

## How to use
| Function | Scope | Description |
| --- | --- | --- | 
| `CreateRemoteObject(string : name)` | Server | Creates a remote object to which you can assign functions. |
| `LoadRemoteObject(string : name)` | Client | Loads a remote object previously created on the server. |

## Example
Server side : 
```lua
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
```

Client side :
```lua
local remoteObject = nil

Citizen.CreateThread(function()
    remoteObject = LoadRemoteObject('ro')
    print(remoteObject.getLocations())   --> table:XXX
    print(remoteObject.bigCalculus())    --> done
    print(remoteObject.multiply(2, 3))   --> 6
end)
```

## Notes
* Loading an undefined remote object may block your thread ;
* Calling an undefined function on a remoite object may block your thread ;
* Loading a remote object from different files may break mutual exclusion and lead to various unexpected results ;
