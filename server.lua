local QBCore = exports['qb-core']:GetCoreObject()

-- Event handler for money collection
RegisterServerEvent('slothy:deliveryGiven')
AddEventHandler('slothy:deliveryGiven', function(dropCount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local reward = math.random(Config.RewardMultiplier.min, Config.RewardMultiplier.max)

    if Player then
        Player.Functions.AddMoney('cash', reward, "Pizza Delivery")
        TriggerClientEvent('QBCore:Notify', src, 'Pizza Delivered $' .. reward, 'success')
    else
        print("Player not found for src:", src)
    end
end)
