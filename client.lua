------------------------------------------------------------
-- Pizza Delivery - A Simple FiveM Script, Made By Slothy#0 --
------------------------------------------------------------
----------------------------------------------------------------------------------------------
                  -- !WARNING! !WARNING! !WARNING! !WARNING! !WARNING! --
        -- DO NOT TOUCH THIS FILE OR YOU /WILL/ MESS SOMETHING UP! EDIT THE CONFIG.LUA --
----------------------------------------------------------------------------------------------

ocal QBCore = exports['qb-core']:GetCoreObject()
local missionActive = false
local dropCount = 0
local currentDrop = nil
local currentBlip = nil
local spawnedDeliveryVehicle = nil

-- ----- Initialization ----- --
Citizen.CreateThread(function()
    SpawnMissionPED()
end)

-- ----- Function Definitions ----- --

-- Function to Spawn Mission PED
function SpawnMissionPED()
    local pedHash = GetHashKey(Config.PEDModel)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Citizen.Wait(0)
    end

    local ped = CreatePed(4, pedHash, Config.PEDSpawn.x, Config.PEDSpawn.y, Config.PEDSpawn.z, Config.PEDSpawn.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Adding target options for the mission PED
    exports['qb-target']:AddEntityZone("mission_ped", ped, {
        name = "mission_ped",
        debugPoly = false,
        useZ = true
    }, {
        options = {
            {
                type = "client",
                event = "slothy:startMission",
                icon = "fas fa-briefcase",
                label = "Start Delivery Mission",
                job = Config.DeliveryJob,
            },
            {
                type = "client",
                event = "slothy:endMission",
                icon = "fas fa-clipboard-check",
                label = "End Delivery Mission",
                job = Config.DeliveryJob,
                canInteract = function()
                    return missionActive
                end
            },
        },
        distance = 2.5
    })
end

-- Function to Spawn Vehicles
function SpawnVehicles(plate)
    local deliveryVehicleSpawn = Config.deliveryVehicleSpawn

    -- Spawn the Delivery Vehicle
    QBCore.Functions.SpawnVehicle(Config.deliveryVehicle, function(vehicle)
        exports["LegacyFuel"]:SetFuel(vehicle, 100)
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, deliveryVehicleSpawn.heading)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))
        spawnedDeliveryVehicle = vehicle
    end, {x = deliveryVehicleSpawn.x, y = deliveryVehicleSpawn.y, z = deliveryVehicleSpawn.z}, true)
end

-- Function to Select Next Drop
function SelectNextDrop()
    if dropCount < #Config.deliverylocations then
        currentDrop = Config.deliverylocations[dropCount + 1]
        QBCore.Functions.Notify('Proceed to the next drop location', 'primary')

        if currentBlip then
            RemoveBlip(currentBlip)
        end

        currentBlip = AddBlipForCoord(currentDrop.x, currentDrop.y, currentDrop.z)
        SetBlipSprite(currentBlip, 1)
        SetBlipDisplay(currentBlip, 4)
        SetBlipScale(currentBlip, 0.8)
        SetBlipColour(currentBlip, 5)
        SetBlipRoute(currentBlip, true)
        SetBlipRouteColour(currentBlip, 5)
    else
        FinishAllDrops()
    end
end

-- Function to Finish All Drops
function FinishAllDrops()
    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end

    currentDrop = nil
    QBCore.Functions.Notify('All deliveries completed. Return to the shop to end the mission.', 'success')
end

-- Function to End Mission
function EndMission()
    missionActive = false
    currentDrop = nil
    dropCount = 0

    if DoesEntityExist(spawnedDeliveryVehicle) then
        DeleteVehicle(spawnedDeliveryVehicle)
        spawnedDeliveryVehicle = nil
    end

    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end

    QBCore.Functions.Notify('Mission ended with ' .. dropCount .. ' drops collected', 'primary')
end

-- ----- Event Handlers ----- --
RegisterNetEvent('slothy:startMission')
AddEventHandler('slothy:startMission', function()
    if missionActive then
        QBCore.Functions.Notify('A mission is already active', 'error')
        return
    end

    missionActive = true
    dropCount = 0
    local plate = "PIZZATHS" -- This is the plate the vehicle will spawn with.

    SpawnVehicles(plate)
    SelectNextDrop()
    Wait(1500)
    QBCore.Functions.Notify('Deliveries are marked on your map... Get to it!')
end)

RegisterNetEvent('slothy:endMission')
AddEventHandler('slothy:endMission', function()
    if missionActive then
        EndMission()
    else
        QBCore.Functions.Notify('No active mission to end', 'error')
    end
end)

-- ----- Main Thread for Drop Off ----- --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if missionActive and currentDrop then
            local playerCoords = GetEntityCoords(PlayerPedId())
            if GetDistanceBetweenCoords(playerCoords, currentDrop.x, currentDrop.y, currentDrop.z, true) < 5.0 then
                DrawText3D(currentDrop.x, currentDrop.y, currentDrop.z, "[E] Drop off the Pizza")
                if IsControlJustReleased(0, 38) then
                    -- Trigger QB Progress Bar
                    QBCore.Functions.Progressbar("deliver_pizza", "Handing Pizza to Customer", 3000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {}, {}, {}, function() -- Done
                        dropCount = dropCount + 1
                        TriggerServerEvent('slothy:deliveryGiven', dropCount)
                        SelectNextDrop()
                    end)
                end
            end
        end
    end
end)

-- Function to Draw Text in 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end
