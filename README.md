# QBCore Dispatch

Integrated with https://github.com/Project-Sloth/nc-mdt

For all support questions, ask in our Discord support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.

https://www.discord.gg/projectsloth

# Installation
* Download ZIP
* Drag and drop resource into your server files
* Start resource through server.cfg
* Drag and drop sounds folder into interact-sound\client\html\sounds
* Restart your server.


# Alert Exports


# Custom Alert Handler
```lua
exports["nc-dispatch"]:CustomAlert({
    coords = vector3(0.0, 0.0, 0.0),
    message = "Criminal Activity",
    dispatchCode = "10-4 Rubber Ducky",
    description = "Blip Name here",
    radius = 0,
    sprite = 64,
    color = 2,
    scale = 1.0,
    length = 3,
})

Table Arguements:

displayCode -- The code for the alert ( 10-4, 10-11, 400-9, etc)
message -- Alert message
gender -- TRUE/FALSE  to enable gender data on the alert
plate  -- Plate of a vehicle
priority -- Priority of the alert
firstColor -- Color of the vehicle
automaticGunfire -- TRUE/FALSE Automatic weapon
camId -- Camera ID
callsign -- Callsign on the player
name -- Name of the player
doorCount -- Number of doors the vehicle has
heading -- Heading of an entity
description -- Name of the blip 
radius -- if the blip has a radius
recipientList -- { "police", "ems", "pbso" } Jobs that get the alert 
blipSprite -- Blip Sprite
blipColour -- Blip Color
blipScale -- Blip Color 
blipLength -- Blip Length : How long it stays on the map
offset -- Offset of the blip
blipflash -- If the blip flashes or not
sound -- GTA sound to play 
sound2 -- GTA sound to play

```

# Preset Alert Exports.

```lua
- exports['nc-dispatch']:VehicleShooting(vehicle)

- exports['nc-dispatch']:Shooting()

- exports['nc-dispatch']:OfficerDown()

- exports['nc-dispatch']:SpeedingVehicle(vehicle)

- exports['nc-dispatch']:Fight()

- exports['nc-dispatch']:InjuriedPerson()

- exports['nc-dispatch']:StoreRobbery(camId)

- exports['nc-dispatch']:FleecaBankRobbery(camId)

- exports['nc-dispatch']:PaletoBankRobbery(camId)

- exports['nc-dispatch']:PacificBankRobbery(camId)

- exports['nc-dispatch']:PrisonBreak()

- exports['nc-dispatch']:VangelicoRobbery(camId)

- exports['nc-dispatch']:HouseRobbery()

- exports['nc-dispatch']:PrisonBreak()

- exports['nc-dispatch']:DrugSale()

- exports['nc-dispatch']:ArtGalleryRobbery()

- exports['nc-dispatch']:HumaneRobery()

- exports['nc-dispatch']:TrainRobbery()

- exports['nc-dispatch']:VanRobbery()

- exports['nc-dispatch']:UndergroundRobbery()

- exports['nc-dispatch']:DrugBoatRobbery()

- exports['nc-dispatch']:UnionRobbery()

- exports['nc-dispatch']:YachtHeist()

- exports['nc-dispatch']:CarBoosting(vehicle)

- exports['nc-dispatch']:CarJacking(vehicle)

- exports['nc-dispatch']:VehicleTheft(vehicle)

- exports['nc-dispatch']:SuspiciousActivity()

- exports['nc-dispatch']:SignRobbery()
```

# Steps to Create New Alert

1. Create a client event that will be triggered from whatever script you want

```lua
local function FleecaBankRobbery(camId)
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    local gender = GetPedGender()
    TriggerServerEvent("dispatch:server:notify",{
        dispatchcodename = "bankrobbery", -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
        dispatchCode = "10-90",
        firstStreet = locationInfo,
        gender = gender,
        camId = camId,
        model = nil,
        plate = nil,
        priority = 2, -- priority
        firstColor = nil,
        automaticGunfire = false,
        origin = {
            x = currentPos.x,
            y = currentPos.y,
            z = currentPos.z
        },
        dispatchMessage = "Fleeca Bank Robbery", -- message
        job = {"police"} -- jobs that will get the alerts
    })
end exports('FleecaBankRobbery', FleecaBankRobbery)
```

2. Add Dispatch Code in sv_dispatchcodes.lua for the particular robbery to display the blip

`["storerobbery"] is the dispatchcodename you passed with the TriggerServerEvent in step 1`
```lua
	["bankrobbery"] =  {displayCode = '10-90', description = "Fleeca Bank Robbery In Progress", radius = 0, recipientList = {'police'}, blipSprite = 500, blipColour = 2, blipScale = 1.5, blipLength = 2, sound = "robberysound"},
```
Information about each parameter is in the file.

# Alerts with Vehicle Information
1. If you want to display vehicle information with a particular alert, you need to pass the vehicle along with the exports like this
```lua 
exports['nc-dispatch']:TestVehicleAlert(vehicle)
```

and its function in nc-dispatch would look like this

```lua
local function TestVehicleAlert(vehicle)
    local vehdata = vehicleData(vehicle)
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    local heading = getCardinalDirectionFromHeading()
    TriggerServerEvent("dispatch:server:notify",{
        dispatchcodename = "speeding", -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
        dispatchCode = "10-11",
        firstStreet = locationInfo,
        model = vehdata.name, -- vehicle name
        plate = vehdata.plate, -- vehicle plate
        priority = 2, 
        firstColor = vehdata.colour, -- vehicle color
        heading = heading, 
        automaticGunfire = false,
        origin = {
            x = currentPos.x,
            y = currentPos.y,
            z = currentPos.z
        },
        dispatchMessage = "Speeding Vehicle",
        job = {"police"}
    })
end 

exports('SpeedingVehicle', SpeedingVehicle)
```

Rest steps will be similar as mentioned above in Steps to create alerts.

# Work to be done

* Hunting Zones
* Locales for alerts